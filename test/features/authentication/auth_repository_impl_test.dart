import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:urbanthread/core/errors/failures.dart';
import 'package:urbanthread/core/network/api_envelope.dart';
import 'package:urbanthread/core/session/session_events.dart';
import 'package:urbanthread/core/storage/preferences_service.dart';
import 'package:urbanthread/core/storage/token_storage.dart';
import 'package:urbanthread/features/authentication/data/datasource/auth_remote_datasource.dart';
import 'package:urbanthread/features/authentication/data/models/auth_models.dart';
import 'package:urbanthread/features/authentication/data/models/user_model.dart';
import 'package:urbanthread/features/authentication/data/repositories/auth_repository_impl.dart';

import '../../helpers/api_fixtures.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockTokenStorage extends Mock implements TokenStorage {}

class MockPreferencesService extends Mock implements PreferencesService {}

/// The repository is where a session starts and ends, so its tests are mostly
/// about side effects rather than return values: what lands in secure storage,
/// what is cached, and — the part that is easy to get wrong — what must *not*
/// be cleared when a call fails.
void main() {
  late MockAuthRemoteDataSource remote;
  late MockTokenStorage tokenStorage;
  late MockPreferencesService preferences;
  late SessionEvents sessionEvents;
  late AuthRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(const LoginRequest(email: '', password: ''));
    registerFallbackValue(
      const RegisterRequest(name: '', email: '', password: ''),
    );
    registerFallbackValue(const EmailRequest(email: ''));
    registerFallbackValue(const ResetPasswordRequest(password: ''));
    registerFallbackValue(
      const ChangePasswordRequest(currentPassword: '', newPassword: ''),
    );
  });

  setUp(() {
    // `UserModel.toEntity` re-bases the avatar URL through `MediaUrl`, which
    // reads the API origin from the environment.
    dotenv.loadFromString(
      envString: 'API_BASE_URL=http://10.0.2.2:5000/api/v1\n',
    );

    remote = MockAuthRemoteDataSource();
    tokenStorage = MockTokenStorage();
    preferences = MockPreferencesService();
    sessionEvents = SessionEvents();

    when(() => tokenStorage.save(any())).thenAnswer((_) async {});
    when(() => tokenStorage.clear()).thenAnswer((_) async {});
    when(() => tokenStorage.hasToken).thenReturn(false);
    when(() => preferences.saveUser(any())).thenAnswer((_) async {});
    when(() => preferences.clearSession()).thenAnswer((_) async {});
    when(() => preferences.cachedUser).thenReturn(null);

    repository = AuthRepositoryImpl(
      remote: remote,
      tokenStorage: tokenStorage,
      preferences: preferences,
      sessionEvents: sessionEvents,
    );
  });

  tearDown(() async {
    await sessionEvents.dispose();
    dotenv.clean();
  });

  Map<String, dynamic> userJson({
    String id = 'u1',
    String name = 'Aarav Sharma',
    String email = 'aarav@example.com',
    String phone = '',
    String avatarUrl = '',
  }) =>
      <String, dynamic>{
        '_id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': 'customer',
        'avatar': <String, dynamic>{'url': avatarUrl, 'publicId': ''},
        'addresses': <Map<String, dynamic>>[],
        'isActive': true,
        'createdAt': '2026-01-05T09:30:00.000Z',
      };

  ApiEnvelope<AuthResponseModel> authEnvelope({
    String token = 'jwt-token',
    Map<String, dynamic>? user,
  }) =>
      envelope(
        AuthResponseModel.fromJson(<String, dynamic>{
          'user': user ?? userJson(),
          'accessToken': token,
        }),
      );

  ApiEnvelope<UserModel> userEnvelope([Map<String, dynamic>? user]) =>
      envelope(UserModel.fromJson(user ?? userJson()));

  T captureRequest<T>(void Function() call) =>
      verify(call).captured.single as T;

  group('login', () {
    test('returns the user and persists the session', () async {
      when(() => remote.login(any())).thenAnswer((_) async => authEnvelope());

      final result = await repository.login(
        email: 'aarav@example.com',
        password: 'Str0ngPass',
      );

      expect(result.valueOrNull?.id, 'u1');
      expect(result.valueOrNull?.email, 'aarav@example.com');
      // The token before the profile: a crash between the two must leave a
      // usable session, not a profile with no way to authenticate.
      verifyInOrder([
        () => tokenStorage.save('jwt-token'),
        () => preferences.saveUser(any()),
      ]);
    });

    test('normalises the email before sending it', () async {
      when(() => remote.login(any())).thenAnswer((_) async => authEnvelope());

      await repository.login(
        email: '  Aarav@Example.COM  ',
        password: 'Str0ngPass',
      );

      final request = captureRequest<LoginRequest>(
        () => remote.login(captureAny()),
      );
      expect(request.email, 'aarav@example.com');
      // The password is never trimmed — a leading space is a legitimate
      // character and trimming it would lock the account out.
      expect(request.password, 'Str0ngPass');
    });

    test('a rejected credential stores nothing', () async {
      when(() => remote.login(any())).thenThrow(
        httpError(401, message: 'Invalid email or password.'),
      );

      final result = await repository.login(
        email: 'aarav@example.com',
        password: 'wrong',
      );

      expect(result.failureOrNull, isA<UnauthorizedFailure>());
      expect(result.failureOrNull?.message, 'Invalid email or password.');
      verifyNever(() => tokenStorage.save(any()));
      verifyNever(() => preferences.saveUser(any()));
    });

    test('carries the 422 field errors through to the domain', () async {
      when(() => remote.login(any())).thenThrow(
        httpError(
          422,
          message: 'Validation failed.',
          errors: [
            {'field': 'email', 'message': 'Enter a valid email address.'},
          ],
        ),
      );

      final result = await repository.login(email: 'nope', password: 'x');
      final failure = result.failureOrNull;

      expect(failure, isA<ValidationFailure>());
      expect(
        (failure! as ValidationFailure).forField('email'),
        'Enter a valid email address.',
      );
    });

    test('a dead connection is a network failure, not a server one', () async {
      when(() => remote.login(any())).thenThrow(connectionError());

      final result = await repository.login(email: 'a@b.com', password: 'x');

      expect(result.failureOrNull, isA<NetworkFailure>());
    });

    test('normalises the empty-string sentinels on the way in', () async {
      when(() => remote.login(any())).thenAnswer(
        (_) async => authEnvelope(
          user: userJson(phone: '', avatarUrl: '/uploads/avatars/a.png'),
        ),
      );

      final user = (await repository.login(
        email: 'a@b.com',
        password: 'Str0ngPass',
      )).valueOrNull;

      // `avatar.url` is `""` for "no avatar", and a stored path is
      // server-relative — both are the API's shapes, neither is the UI's.
      expect(user?.avatarUrl, 'http://10.0.2.2:5000/uploads/avatars/a.png');
      expect(user?.phone, '');
    });
  });

  group('register', () {
    test('trims the name and omits a blank phone', () async {
      when(() => remote.register(any())).thenAnswer((_) async => authEnvelope());

      await repository.register(
        name: '  Aarav Sharma ',
        email: 'aarav@example.com',
        password: 'Str0ngPass',
        phone: '   ',
      );

      final request = captureRequest<RegisterRequest>(
        () => remote.register(captureAny()),
      );
      expect(request.name, 'Aarav Sharma');
      // The validator rejects an empty string but accepts an absent key, so
      // "no phone" has to be null rather than "".
      expect(request.phone, isNull);
      expect(request.toJson().containsKey('phone'), isFalse);
    });

    test('sends a phone that was actually given', () async {
      when(() => remote.register(any())).thenAnswer((_) async => authEnvelope());

      await repository.register(
        name: 'Aarav Sharma',
        email: 'aarav@example.com',
        password: 'Str0ngPass',
        phone: ' +9779812345678 ',
      );

      expect(
        captureRequest<RegisterRequest>(
          () => remote.register(captureAny()),
        ).phone,
        '+9779812345678',
      );
    });

    test('a taken email is a conflict', () async {
      when(() => remote.register(any())).thenThrow(
        httpError(409, message: 'An account with that email already exists.'),
      );

      final result = await repository.register(
        name: 'Aarav Sharma',
        email: 'aarav@example.com',
        password: 'Str0ngPass',
      );

      expect(result.failureOrNull, isA<ConflictFailure>());
      expect(
        result.failureOrNull?.message,
        'An account with that email already exists.',
      );
    });
  });

  group('logout', () {
    test('clears the session even when the server call fails', () async {
      when(() => remote.logout()).thenThrow(connectionError());

      final result = await repository.logout();

      // The user asked to be signed out; refusing because the network is down
      // would trap them in a session they no longer want.
      expect(result.isSuccess, isTrue);
      verify(() => tokenStorage.clear()).called(1);
      verify(() => preferences.clearSession()).called(1);
    });

    test('tells the server first, while the token is still attached', () async {
      when(() => remote.logout()).thenAnswer(
        (_) async => envelope<dynamic>(null),
      );

      await repository.logout();

      verifyInOrder([
        () => remote.logout(),
        () => tokenStorage.clear(),
      ]);
    });
  });

  group('logoutAll', () {
    test('clears the session when the server accepted it', () async {
      when(() => remote.logoutAll()).thenAnswer(
        (_) async => envelope<dynamic>(null),
      );

      final result = await repository.logoutAll();

      expect(result.isSuccess, isTrue);
      verify(() => tokenStorage.clear()).called(1);
    });

    test('keeps the session when the request never landed', () async {
      when(() => remote.logoutAll()).thenThrow(connectionError());

      final result = await repository.logoutAll();

      // Revoking other devices' tokens only means something if the server
      // received it. Clearing locally would report a revocation that never
      // happened.
      expect(result.failureOrNull, isA<NetworkFailure>());
      verifyNever(() => tokenStorage.clear());
      verifyNever(() => preferences.clearSession());
    });
  });

  group('getCurrentUser', () {
    test('re-caches the profile it received', () async {
      when(() => remote.getCurrentUser()).thenAnswer(
        (_) async => userEnvelope(userJson(name: 'Aarav Sharma')),
      );

      final result = await repository.getCurrentUser();

      expect(result.valueOrNull?.name, 'Aarav Sharma');
      verify(() => preferences.saveUser(any())).called(1);
    });

    test('falls back to the cached profile when offline', () async {
      when(() => preferences.cachedUser).thenReturn(userJson(name: 'Cached'));
      when(() => remote.getCurrentUser()).thenThrow(connectionError());

      final result = await repository.getCurrentUser();

      expect(result.valueOrNull?.name, 'Cached');
    });

    test('reports the failure when offline with nothing cached', () async {
      when(() => remote.getCurrentUser()).thenThrow(timeoutError());

      final result = await repository.getCurrentUser();

      expect(result.failureOrNull, isA<TimeoutFailure>());
    });

    test('a 401 is never softened by the cache', () async {
      when(() => preferences.cachedUser).thenReturn(userJson());
      when(() => remote.getCurrentUser()).thenThrow(httpError(401));

      final result = await repository.getCurrentUser();

      // Serving a cached profile here would keep a revoked session alive on
      // screen. Offline is transient; a 401 is terminal.
      expect(result.failureOrNull, isA<UnauthorizedFailure>());
    });
  });

  group('cachedUser', () {
    test('decodes what preferences hold', () {
      when(() => preferences.cachedUser).thenReturn(userJson(name: 'Aarav'));

      expect(repository.cachedUser?.name, 'Aarav');
    });

    test('is null when nothing is stored', () {
      expect(repository.cachedUser, isNull);
    });

    test('is null rather than throwing on a shape it cannot parse', () {
      // What an upgrade from an older build looks like: the key is there, the
      // fields are not. `getCurrentUser` replaces it on the next request.
      when(() => preferences.cachedUser).thenReturn(<String, dynamic>{
        'legacyId': 'u1',
      });

      expect(repository.cachedUser, isNull);
    });
  });

  group('hasSession', () {
    test('reflects whether a token is held', () {
      when(() => tokenStorage.hasToken).thenReturn(true);
      expect(repository.hasSession, isTrue);

      when(() => tokenStorage.hasToken).thenReturn(false);
      expect(repository.hasSession, isFalse);
    });
  });

  group('changePassword', () {
    test('returns the refreshed user', () async {
      when(() => remote.changePassword(any())).thenAnswer(
        (_) async => userEnvelope(),
      );

      final result = await repository.changePassword(
        currentPassword: 'Str0ngPass',
        newPassword: 'Str0ngerPass1',
      );

      expect(result.valueOrNull?.id, 'u1');
      final request = captureRequest<ChangePasswordRequest>(
        () => remote.changePassword(captureAny()),
      );
      expect(request.currentPassword, 'Str0ngPass');
      expect(request.newPassword, 'Str0ngerPass1');
    });

    test('a wrong current password keeps the server message', () async {
      when(() => remote.changePassword(any())).thenThrow(
        httpError(401, message: 'Your current password is incorrect.'),
      );

      final result = await repository.changePassword(
        currentPassword: 'nope',
        newPassword: 'Str0ngerPass1',
      );

      expect(
        result.failureOrNull?.message,
        'Your current password is incorrect.',
      );
    });
  });

  group('message-only endpoints', () {
    test('forgotPassword returns the server message verbatim', () async {
      const vague = 'If an account exists for that address, a link is on its '
          'way.';
      when(() => remote.forgotPassword(any())).thenAnswer(
        (_) async => envelope<dynamic>(null, message: vague),
      );

      final result = await repository.forgotPassword('  Aarav@Example.com ');

      // Replacing this with a friendlier, more definite string would leak
      // exactly what the endpoint withholds: whether the address is
      // registered.
      expect(result.valueOrNull, vague);
      expect(
        captureRequest<EmailRequest>(
          () => remote.forgotPassword(captureAny()),
        ).email,
        'aarav@example.com',
      );
    });

    test('the strict rate limit surfaces as its own failure', () async {
      when(() => remote.forgotPassword(any())).thenThrow(
        httpError(429, message: 'Too many requests.'),
      );

      final result = await repository.forgotPassword('aarav@example.com');

      expect(result.failureOrNull, isA<RateLimitFailure>());
    });
  });

  group('resetPassword', () {
    test('drops the local session on success', () async {
      when(() => remote.resetPassword(any(), any())).thenAnswer(
        (_) async => envelope<dynamic>(null, message: 'Password updated.'),
      );

      final result = await repository.resetPassword(
        token: 'reset-token',
        password: 'Str0ngerPass1',
      );

      // The reset bumped `tokenVersion`, so whatever token this device holds
      // is already dead — keeping it would send a credential the server has
      // revoked on every subsequent request.
      expect(result.valueOrNull, 'Password updated.');
      verify(() => tokenStorage.clear()).called(1);
      verify(() => preferences.clearSession()).called(1);
    });

    test('keeps the session when the token was refused', () async {
      when(() => remote.resetPassword(any(), any())).thenThrow(
        httpError(400, message: 'This reset link has expired.'),
      );

      final result = await repository.resetPassword(
        token: 'stale',
        password: 'Str0ngerPass1',
      );

      expect(result.failureOrNull, isA<ValidationFailure>());
      verifyNever(() => tokenStorage.clear());
    });
  });

  group('onSessionExpired', () {
    test('relays what core broadcasts', () async {
      // The interceptor cannot import this feature, so a 401 arrives through
      // core's stream rather than a direct call.
      final expired = expectLater(repository.onSessionExpired, emits(null));

      sessionEvents.notifyExpired();

      await expired;
    });
  });
}
