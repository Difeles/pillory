/// The signed-in person.
class CloudUser {
  const CloudUser({required this.uid, required this.email});

  final String uid;
  final String email;
}

/// What the cloud holds: one backup file's text and its revision, which
/// counts up with every upload.
class CloudSnapshot {
  const CloudSnapshot({
    required this.json,
    required this.revision,
    required this.updatedAt,
  });

  final String json;
  final int revision;
  final DateTime updatedAt;
}

/// Somebody else uploaded in the meantime: the revision is no longer the one
/// the caller knew.
class CloudConflictException implements Exception {
  const CloudConflictException();
}

/// The backup does not fit the cloud's size limit.
class CloudTooLargeException implements Exception {
  const CloudTooLargeException();
}

enum CloudAuthProblem {
  invalidEmail,
  wrongCredentials,
  emailInUse,
  weakPassword,
  network,
  tooManyRequests,
  other,
}

/// Sign-in failed or was refused; [problem] says how, for the user.
class CloudAuthException implements Exception {
  const CloudAuthException(this.problem);

  final CloudAuthProblem problem;

  @override
  String toString() => 'CloudAuthException($problem)';
}

/// Accounts and the one backup each account keeps. Implemented on Firebase in
/// `firebase_cloud_service.dart`.
abstract interface class CloudService {
  /// False when no cloud is connected to this build.
  bool get available;

  /// The signed-in user now, then every change.
  Stream<CloudUser?> watchUser();

  Future<void> register(String email, String password);
  Future<void> signIn(String email, String password);
  Future<void> signOut();
  Future<void> sendPasswordReset(String email);

  /// Deletes the account and its backup. Needs a recent sign-in; throws
  /// [CloudAuthException] with [CloudAuthProblem.wrongCredentials] when
  /// [password] does not match.
  Future<void> deleteAccount(String password);

  /// The backup, or null when the account has none yet.
  Future<CloudSnapshot?> fetch();

  /// Stores [json] as revision `expectedRevision + 1` and returns that
  /// revision. [expectedRevision] is null for the first upload; a different
  /// revision in the cloud throws [CloudConflictException].
  Future<int> push(String json, {required int? expectedRevision});
}

/// Used when no cloud is connected (tests, a build without Firebase).
class NoCloudService implements CloudService {
  const NoCloudService();

  @override
  bool get available => false;

  @override
  Stream<CloudUser?> watchUser() => Stream.value(null);

  @override
  Future<void> register(String email, String password) async =>
      throw const CloudAuthException(CloudAuthProblem.other);

  @override
  Future<void> signIn(String email, String password) async =>
      throw const CloudAuthException(CloudAuthProblem.other);

  @override
  Future<void> signOut() async {}

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> deleteAccount(String password) async {}

  @override
  Future<CloudSnapshot?> fetch() async => null;

  @override
  Future<int> push(String json, {required int? expectedRevision}) async =>
      throw const CloudConflictException();
}
