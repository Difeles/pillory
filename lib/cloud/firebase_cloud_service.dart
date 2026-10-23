import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'cloud_service.dart';

/// [CloudService] on Firebase Auth (email and password) and Firestore: one
/// document per user, `users/{uid}`, holding the gzipped backup.
class FirebaseCloudService implements CloudService {
  FirebaseCloudService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  /// A Firestore document may hold 1 MiB; this leaves room for its fields.
  static const maxBytes = 900 * 1024;

  @override
  bool get available => true;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('users').doc(uid);

  String get _uid {
    final u = _auth.currentUser;
    if (u == null) throw const CloudAuthException(CloudAuthProblem.other);
    return u.uid;
  }

  CloudUser? _user(User? u) =>
      u == null ? null : CloudUser(uid: u.uid, email: u.email ?? '');

  @override
  Stream<CloudUser?> watchUser() => _auth.userChanges().map(_user);

  Future<T> _auth_<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on FirebaseAuthException catch (e) {
      throw CloudAuthException(switch (e.code) {
        'invalid-email' => CloudAuthProblem.invalidEmail,
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' => CloudAuthProblem.wrongCredentials,
        'email-already-in-use' => CloudAuthProblem.emailInUse,
        'weak-password' => CloudAuthProblem.weakPassword,
        'network-request-failed' => CloudAuthProblem.network,
        'too-many-requests' => CloudAuthProblem.tooManyRequests,
        _ => CloudAuthProblem.other,
      });
    }
  }

  @override
  Future<void> register(String email, String password) => _auth_(
    () => _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    ),
  );

  @override
  Future<void> signIn(String email, String password) => _auth_(
    () => _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    ),
  );

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> sendPasswordReset(String email) =>
      _auth_(() => _auth.sendPasswordResetEmail(email: email.trim()));

  @override
  Future<void> deleteAccount(String password) => _auth_(() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.reauthenticateWithCredential(
      EmailAuthProvider.credential(email: user.email ?? '', password: password),
    );
    await _doc(user.uid).delete();
    await user.delete();
  });

  @override
  Future<CloudSnapshot?> fetch() async {
    final snap = await _doc(_uid).get();
    final data = snap.data();
    if (data == null) return null;
    final blob = data['backup'];
    if (blob is! Blob) return null;
    return CloudSnapshot(
      json: utf8.decode(gzip.decode(blob.bytes)),
      revision: (data['revision'] as num?)?.toInt() ?? 0,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  Future<int> push(String json, {required int? expectedRevision}) async {
    final bytes = Uint8List.fromList(gzip.encode(utf8.encode(json)));
    if (bytes.length > maxBytes) throw const CloudTooLargeException();
    final ref = _doc(_uid);
    return _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = snap.exists
          ? (snap.data()?['revision'] as num?)?.toInt() ?? 0
          : null;
      if (current != expectedRevision) throw const CloudConflictException();
      final next = (current ?? 0) + 1;
      tx.set(ref, {
        'backup': Blob(bytes),
        'revision': next,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return next;
    });
  }
}
