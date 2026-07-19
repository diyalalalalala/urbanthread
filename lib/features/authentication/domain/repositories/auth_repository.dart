import '../../../../core/domain/result.dart';
import '../entities/user.dart';

/// The authentication contract the domain depends on.
///
/// Declared here, implemented in `data/` — so use cases point inward at an
/// abstraction and know nothing about Dio, Hive or the shape of the API.
abstract interface class AuthRepository {
  /// Creates an account and signs in. The account is usable immediately, but
  /// verification-gated routes (checkout, reviews) stay closed until the
  /// address is confirmed.
  Future<Result<User>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  });

  Future<Result<User>> login({
    required String email,
    required String password,
  });

  /// Ends this session. Succeeds locally even if the network call fails —
  /// the user asked to be signed out, and refusing would trap them.
  Future<Result<void>> logout();

  /// Ends every session for this account by bumping `tokenVersion`.
  Future<Result<void>> logoutAll();

  /// The signed-in user, refreshed from the server.
  Future<Result<User>> getCurrentUser();

  /// The last known user, read from local storage. Used to render a
  /// signed-in shell at launch without waiting on the network.
  User? get cachedUser;

  /// True when a token is held. Says nothing about whether it is still
  /// valid — only the server can answer that.
  bool get hasSession;

  Future<Result<User>> verifyEmail(String token);

  Future<Result<String>> resendVerification(String email);

  /// Always reports success for an unknown address — the endpoint refuses to
  /// confirm whether an account exists.
  Future<Result<String>> forgotPassword(String email);

  /// Invalidates every existing token, including the caller's.
  Future<Result<String>> resetPassword({
    required String token,
    required String password,
  });

  Future<Result<User>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Fires when a 401 ended the session involuntarily.
  Stream<void> get onSessionExpired;
}
