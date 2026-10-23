// The constructor takes public named parameters for private fields.
// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../cloud/cloud_service.dart';
import '../data/backup_format.dart';
import '../data/drift_backup_repository.dart';
import '../domain/extras.dart';

enum CloudPhase {
  /// Nobody is signed in.
  signedOut,

  /// Signed in and the cloud has what this device has.
  idle,
  syncing,

  /// The device and the cloud both changed: the user chooses which one wins.
  conflict,

  /// The last attempt failed; see [CloudSyncState.problem].
  error,
}

enum CloudSyncProblem { network, tooLarge, other }

class CloudSyncState {
  const CloudSyncState({
    this.phase = CloudPhase.signedOut,
    this.user,
    this.syncedAt,
    this.problem,
  });

  final CloudPhase phase;
  final CloudUser? user;
  final DateTime? syncedAt;
  final CloudSyncProblem? problem;

  CloudSyncState copy({
    CloudPhase? phase,
    CloudUser? user,
    DateTime? syncedAt,
    CloudSyncProblem? problem,
  }) => CloudSyncState(
    phase: phase ?? this.phase,
    user: user ?? this.user,
    syncedAt: syncedAt ?? this.syncedAt,
    problem: problem,
  );
}

/// One stream that fires whenever any of [streams] does.
Stream<void> mergeSignals(List<Stream<void>> streams) {
  late final StreamController<void> c;
  final subs = <StreamSubscription<void>>[];
  c = StreamController<void>.broadcast(
    onListen: () {
      for (final s in streams) {
        subs.add(s.listen((_) => c.add(null)));
      }
    },
    onCancel: () async {
      for (final s in subs) {
        await s.cancel();
      }
      subs.clear();
    },
  );
  return c.stream;
}

/// Whether a backup holds anything the user made (not just default settings).
bool hasUserData(BackupData d) =>
    d.medicines.isNotEmpty || d.diary.isNotEmpty || d.shopping.isNotEmpty;

/// Keeps one backup of this device's data in the cloud account: the whole
/// database as the backup file, with a revision that stops two devices from
/// overwriting each other unseen.
///
/// - First sign-in: an empty cloud takes this device's data; an empty device
///   takes the cloud's; when both have data the user chooses.
/// - Afterwards every local change is uploaded a few seconds later, and on
///   return to the app a newer cloud revision is downloaded, or, if this
///   device changed too, offered as a conflict.
class CloudSync with WidgetsBindingObserver {
  CloudSync({
    required CloudService cloud,
    required DriftBackupRepository backups,
    required ExtrasRepository extras,
    required Stream<void> localChanges,
    required Future<void> Function() afterRestore,
    this.debounce = const Duration(seconds: 4),
    DateTime Function()? now,
  }) : _cloud = cloud,
       _backups = backups,
       _extras = extras,
       _localChanges = localChanges,
       _afterRestore = afterRestore,
       _now = now ?? DateTime.now;

  final CloudService _cloud;
  final DriftBackupRepository _backups;
  final ExtrasRepository _extras;
  final Stream<void> _localChanges;
  final Future<void> Function() _afterRestore;
  final Duration debounce;
  final DateTime Function() _now;

  final state = ValueNotifier(const CloudSyncState());

  StreamSubscription<CloudUser?>? _userSub;
  StreamSubscription<void>? _changeSub;
  Timer? _timer;
  bool _dirty = false;
  bool _syncQueued = false;

  /// Steps run one after another, never overlapping.
  Future<void> _lock = Future.value();
  DateTime? _ignoreChangesUntil;
  CloudSnapshot? _conflictRemote;

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _userSub = _cloud.watchUser().listen(_onUser);
    _changeSub = _localChanges.listen((_) {
      final until = _ignoreChangesUntil;
      if (until != null && _now().isBefore(until)) return;
      _markDirty();
      _schedule();
    });
  }

  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    await _userSub?.cancel();
    await _changeSub?.cancel();
    state.dispose();
  }

  @override
  // ignore: avoid_renaming_method_parameters
  void didChangeAppLifecycleState(AppLifecycleState life) {
    if (life == AppLifecycleState.resumed) syncNow();
  }

  /// Completes when no sync is running (for tests).
  Future<void> get idle async {
    Future<void> last;
    do {
      last = _lock;
      await last;
    } while (!identical(last, _lock));
  }

  void _set(CloudSyncState s) => state.value = s;

  /// Remembered across launches, so a change that was never uploaded still
  /// is after a restart.
  void _markDirty() {
    if (_dirty) return;
    _dirty = true;
    unawaited(_extras.setPref(PrefKey.cloudDirty, '1'));
  }

  Future<void> _markClean() async {
    _dirty = false;
    await _extras.setPref(PrefKey.cloudDirty, '');
  }

  Future<void> _onUser(CloudUser? user) async {
    if (user == null) {
      _timer?.cancel();
      _conflictRemote = null;
      _set(const CloudSyncState());
      return;
    }
    if (state.value.user?.uid == user.uid) return;
    _set(CloudSyncState(phase: CloudPhase.syncing, user: user));
    _dirty = (await _extras.getPref(PrefKey.cloudDirty)) == '1';
    await _guard(() => _firstSync(user));
  }

  Future<void> _firstSync(CloudUser user) async {
    final remote = await _cloud.fetch();
    final local = await _backups.read();
    final storedUid = await _extras.getPref(PrefKey.cloudUid);
    final storedRev = int.tryParse(
      await _extras.getPref(PrefKey.cloudRevision) ?? '',
    );
    if (remote == null) {
      if (hasUserData(local)) {
        await _push(user, local, expected: null);
      } else {
        // Nothing on either side: there is nothing to upload yet.
        await _remember(user, null);
      }
    } else if (!hasUserData(local)) {
      await _pull(user, remote);
    } else if (storedUid == user.uid && storedRev != null) {
      // The same account as before: an ordinary sync.
      await _reconcile(user, remote, storedRev);
    } else {
      _conflictRemote = remote;
      _set(state.value.copy(phase: CloudPhase.conflict));
    }
  }

  /// Syncs now: uploads local changes, downloads a newer cloud revision.
  Future<void> syncNow() async {
    final user = state.value.user;
    if (user == null ||
        _syncQueued ||
        state.value.phase == CloudPhase.conflict) {
      return;
    }
    _syncQueued = true;
    _set(state.value.copy(phase: CloudPhase.syncing));
    try {
      await _guard(() async {
        final remote = await _cloud.fetch();
        final storedRev = int.tryParse(
          await _extras.getPref(PrefKey.cloudRevision) ?? '',
        );
        await _reconcile(user, remote, storedRev);
      });
    } finally {
      _syncQueued = false;
    }
  }

  /// One sync against the cloud's [remote] snapshot, given the revision this
  /// device last synced ([storedRev]).
  Future<void> _reconcile(
    CloudUser user,
    CloudSnapshot? remote,
    int? storedRev,
  ) async {
    if (remote == null) {
      final local = await _backups.read();
      if (hasUserData(local)) {
        await _push(user, local, expected: null);
      } else {
        _set(state.value.copy(phase: CloudPhase.idle));
      }
    } else if (remote.revision == storedRev) {
      if (_dirty) {
        await _push(user, await _backups.read(), expected: storedRev);
      } else {
        _set(state.value.copy(phase: CloudPhase.idle));
      }
    } else if (!_dirty && (storedRev == null || remote.revision > storedRev)) {
      await _pull(user, remote);
    } else {
      _conflictRemote = remote;
      _set(state.value.copy(phase: CloudPhase.conflict));
    }
  }

  /// Settles a conflict: the cloud's data replaces this device's, or this
  /// device's replaces the cloud's.
  Future<void> resolve({required bool useCloud}) async {
    final user = state.value.user;
    if (user == null || state.value.phase != CloudPhase.conflict) return;
    _set(state.value.copy(phase: CloudPhase.syncing));
    await _guard(() async {
      final remote = _conflictRemote ?? await _cloud.fetch();
      _conflictRemote = null;
      if (remote == null) {
        await _push(user, await _backups.read(), expected: null);
      } else if (useCloud) {
        await _pull(user, remote);
      } else {
        await _push(user, await _backups.read(), expected: remote.revision);
      }
    });
  }

  Future<void> signOut() async {
    await _cloud.signOut();
    await _forget();
  }

  Future<void> deleteAccount(String password) async {
    await _cloud.deleteAccount(password);
    await _forget();
  }

  Future<void> _forget() async {
    _timer?.cancel();
    await _markClean();
    _conflictRemote = null;
    await _extras.setPref(PrefKey.cloudUid, '');
    await _extras.setPref(PrefKey.cloudRevision, '');
    await _extras.setPref(PrefKey.cloudSyncedAt, '');
    _set(const CloudSyncState());
  }

  void _schedule() {
    if (state.value.user == null ||
        state.value.phase == CloudPhase.conflict ||
        state.value.phase == CloudPhase.signedOut) {
      return;
    }
    _timer?.cancel();
    _timer = Timer(debounce, _flush);
  }

  Future<void> _flush() async {
    final user = state.value.user;
    if (user == null || !_dirty) return;
    await _guard(() async {
      _set(state.value.copy(phase: CloudPhase.syncing));
      final storedRev = int.tryParse(
        await _extras.getPref(PrefKey.cloudRevision) ?? '',
      );
      await _push(user, await _backups.read(), expected: storedRev);
    });
  }

  Future<void> _push(
    CloudUser user,
    BackupData data, {
    required int? expected,
  }) async {
    final rev = await _cloud.push(
      encodeBackup(data),
      expectedRevision: expected,
    );
    await _markClean();
    await _remember(user, rev);
  }

  Future<void> _pull(CloudUser user, CloudSnapshot remote) async {
    final data = parseBackup(Uint8List.fromList(utf8.encode(remote.json)));
    // Restoring touches every table: those are not the user's changes.
    _ignoreChangesUntil = _now().add(const Duration(seconds: 2));
    await _backups.restore(data);
    await _afterRestore();
    await _markClean();
    await _remember(user, remote.revision);
  }

  Future<void> _remember(CloudUser user, int? revision) async {
    final at = _now();
    await _extras.setPref(PrefKey.cloudUid, user.uid);
    await _extras.setPref(
      PrefKey.cloudRevision,
      revision == null ? '' : '$revision',
    );
    await _extras.setPref(PrefKey.cloudSyncedAt, at.toIso8601String());
    _set(CloudSyncState(phase: CloudPhase.idle, user: user, syncedAt: at));
  }

  /// Runs one sync step; a failure becomes the state, never an exception.
  Future<void> _guard(Future<void> Function() step) {
    final next = _lock.then((_) => _run(step));
    _lock = next;
    return next;
  }

  Future<void> _run(Future<void> Function() step) async {
    try {
      await step();
    } on CloudConflictException {
      // Somebody uploaded meanwhile: let the user choose.
      try {
        _conflictRemote = await _cloud.fetch();
        _set(state.value.copy(phase: CloudPhase.conflict));
      } on Object {
        _set(
          state.value.copy(
            phase: CloudPhase.error,
            problem: CloudSyncProblem.network,
          ),
        );
      }
    } on CloudTooLargeException {
      _set(
        state.value.copy(
          phase: CloudPhase.error,
          problem: CloudSyncProblem.tooLarge,
        ),
      );
    } on BackupException {
      _set(
        state.value.copy(
          phase: CloudPhase.error,
          problem: CloudSyncProblem.other,
        ),
      );
    } on Object catch (e) {
      debugPrint('Cloud sync failed: $e');
      _set(
        state.value.copy(
          phase: CloudPhase.error,
          problem: CloudSyncProblem.network,
        ),
      );
    }
  }
}
