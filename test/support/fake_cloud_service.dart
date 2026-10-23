import 'dart:async';

import 'package:pillory/cloud/cloud_service.dart';

/// An in-memory cloud: one account per email, one backup per account.
class FakeCloudService implements CloudService {
  final _users = StreamController<CloudUser?>.broadcast(sync: true);
  CloudUser? _current;
  final _snapshots = <String, CloudSnapshot>{};
  final _passwords = <String, String>{};
  int pushes = 0;
  bool offline = false;

  @override
  bool get available => true;

  @override
  Stream<CloudUser?> watchUser() => Stream.multi((c) {
    c.add(_current);
    final sub = _users.stream.listen(c.add);
    c.onCancel = sub.cancel;
  });

  void _login(CloudUser u) {
    _current = u;
    _users.add(u);
  }

  CloudUser _user(String email) =>
      CloudUser(uid: 'uid-${email.hashCode}', email: email);

  @override
  Future<void> register(String email, String password) async {
    if (_passwords.containsKey(email)) {
      throw const CloudAuthException(CloudAuthProblem.emailInUse);
    }
    _passwords[email] = password;
    _login(_user(email));
  }

  @override
  Future<void> signIn(String email, String password) async {
    if (_passwords[email] != password) {
      throw const CloudAuthException(CloudAuthProblem.wrongCredentials);
    }
    _login(_user(email));
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _users.add(null);
  }

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> deleteAccount(String password) async {
    final u = _current!;
    if (_passwords[u.email] != password) {
      throw const CloudAuthException(CloudAuthProblem.wrongCredentials);
    }
    _passwords.remove(u.email);
    _snapshots.remove(u.uid);
    await signOut();
  }

  void _check() {
    if (offline) throw const CloudAuthException(CloudAuthProblem.network);
  }

  @override
  Future<CloudSnapshot?> fetch() async {
    _check();
    return _snapshots[_current!.uid];
  }

  @override
  Future<int> push(String json, {required int? expectedRevision}) async {
    _check();
    final uid = _current!.uid;
    final current = _snapshots[uid]?.revision;
    if (current != expectedRevision) throw const CloudConflictException();
    pushes++;
    final next = (current ?? 0) + 1;
    _snapshots[uid] = CloudSnapshot(
      json: json,
      revision: next,
      updatedAt: DateTime.now(),
    );
    return next;
  }

  /// Test hook: what another device left in the cloud for [email].
  void plant(String email, String json, int revision) {
    _snapshots[_user(email).uid] = CloudSnapshot(
      json: json,
      revision: revision,
      updatedAt: DateTime.now(),
    );
  }

  CloudSnapshot? snapshotOf(String email) => _snapshots[_user(email).uid];
}
