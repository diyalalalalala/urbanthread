import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:urbanthread/core/domain/result.dart';
import 'package:urbanthread/core/errors/failures.dart';
import 'package:urbanthread/features/authentication/domain/entities/user.dart';
import 'package:urbanthread/features/authentication/domain/repositories/auth_repository.dart';
import 'package:urbanthread/features/authentication/presentation/providers/auth_notifier.dart';
import 'package:urbanthread/features/authentication/presentation/providers/auth_providers.dart';
import 'package:urbanthread/features/authentication/presentation/providers/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

/// The notifier owns the one decision that cannot be got wrong: when to sign
/// someone out. Launch, a dropped connection and a revoked token all look
/// similar from here and have to end differently, so each path is pinned.
void main() {
  const serverUser = User(
    id: 'u1',
    name: 'Aarav Sharma',
    email: 'aarav@example.com',
    isEmailVerified: true,
  );
  const cachedUser = User(
    id: 'u1',
    name: 'Aarav (cached)',
    email: 'aarav@example.com',
  );

  late MockAuthRepository repository;
  late StreamController<void> sessionExpired;

  setUp(() {
    repository = MockAuthRepository();
    sessionExpired = StreamController<void>.broadcast();

    when(() => repository.onSessionExpired)
        .thenAnswer((_) => sessionExpired.stream);
    when(() => repository.hasSession).thenReturn(false);
    when(() => repository.cachedUser).thenReturn(null);
    when(() => repository.getCurrentUser())
        .thenAnswer((_) async => const Result.success(serverUser));
  });

  tearDown(() => sessionExpired.close());

  ProviderContainer makeContainer() => ProviderContainer.test(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );

  /// Signs in with a token and a cached profile already on disk, then lets the
  /// background `/auth/me` settle — the state every screen-level test starts
  /// from.
  Future<ProviderContainer> signedIn() async {
    when(() => repository.hasSession).thenReturn(true);
    when(() => repository.cachedUser).thenReturn(cachedUser);

    final container = makeContainer();
    container.read(authProvider);
    await pumpEventQueue();
    return container;
  }

  group('build', () {
    test('no token resolves straight to signed out', () async {
      final container = makeContainer();

      final state = container.read(authProvider);

      expect(state.status, AuthStatus.unauthenticated);
      expect(state.isResolved, isTrue);
      // Nothing to confirm, so no request — a cold start on a signed-out
      // device should not touch the network at all.
      verifyNever(() => repository.getCurrentUser());
    });

    test('a cached profile paints a signed-in shell before /me answers',
        () async {
      when(() => repository.hasSession).thenReturn(true);
      when(() => repository.cachedUser).thenReturn(cachedUser);
      final container = makeContainer();

      final atLaunch = container.read(authProvider);

      expect(atLaunch.status, AuthStatus.authenticated);
      expect(atLaunch.user, cachedUser);

      await pumpEventQueue();

      // The server's copy replaces the cached one once it arrives.
      expect(container.read(authProvider).user, serverUser);
    });

    test('a token with no cached profile starts unknown, not signed out',
        () async {
      when(() => repository.hasSession).thenReturn(true);
      final container = makeContainer();

      // Collapsing unknown into unauthenticated would bounce a signed-in user
      // to the login screen for a frame before redirecting back.
      expect(container.read(authProvider).status, AuthStatus.unknown);
      expect(container.read(authProvider).isResolved, isFalse);

      await pumpEventQueue();

      expect(container.read(authProvider).status, AuthStatus.authenticated);
    });

    test('an offline refresh keeps the cached session', () async {
      when(() => repository.hasSession).thenReturn(true);
      when(() => repository.cachedUser).thenReturn(cachedUser);
      when(() => repository.getCurrentUser())
          .thenAnswer((_) async => const Result.failure(NetworkFailure()));
      final container = makeContainer();
      container.read(authProvider);

      await pumpEventQueue();

      // Forcing a re-login the moment someone walks into a lift would be
      // hostile, and the token is very likely still good.
      expect(container.read(authProvider).status, AuthStatus.authenticated);
      expect(container.read(authProvider).user, cachedUser);
    });

    test('a 5xx on refresh also keeps the session', () async {
      when(() => repository.hasSession).thenReturn(true);
      when(() => repository.cachedUser).thenReturn(cachedUser);
      when(() => repository.getCurrentUser())
          .thenAnswer((_) async => const Result.failure(ServerFailure()));
      final container = makeContainer();
      container.read(authProvider);

      await pumpEventQueue();

      expect(container.read(authProvider).status, AuthStatus.authenticated);
    });

    test('a revoked token signs the user out', () async {
      when(() => repository.hasSession).thenReturn(true);
      when(() => repository.cachedUser).thenReturn(cachedUser);
      when(() => repository.getCurrentUser())
          .thenAnswer((_) async => const Result.failure(UnauthorizedFailure()));
      final container = makeContainer();
      container.read(authProvider);

      await pumpEventQueue();

      final state = container.read(authProvider);
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.user, isNull);
      expect(state.failure, isA<UnauthorizedFailure>());
    });

    test('a token with no cached profile and a dead network resolves to '
        'signed out', () async {
      when(() => repository.hasSession).thenReturn(true);
      when(() => repository.getCurrentUser())
          .thenAnswer((_) async => const Result.failure(NetworkFailure()));
      final container = makeContainer();
      container.read(authProvider);

      await pumpEventQueue();

      // There is no cached user to keep on screen, so staying in `unknown`
      // would hang the splash screen forever.
      expect(container.read(authProvider).status, AuthStatus.unauthenticated);
    });
  });

  group('login', () {
    test('reports success and flips the submitting flag on the way', () async {
      when(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Result.success(serverUser));
      final container = makeContainer();

      final pending = container.read(authProvider.notifier).login(
            email: 'aarav@example.com',
            password: 'Str0ngPass',
          );

      // The form disables its submit button off this flag, so it has to be
      // observably true while the request is still in flight.
      expect(container.read(authProvider).isSubmitting, isTrue);
      expect(await pending, isTrue);
      expect(container.read(authProvider).user, serverUser);
      expect(container.read(authProvider).isSubmitting, isFalse);
    });

    test('a rejected credential leaves the failure on the state', () async {
      when(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const Result.failure(
          UnauthorizedFailure('Invalid email or password.'),
        ),
      );
      final container = makeContainer();

      final succeeded = await container.read(authProvider.notifier).login(
            email: 'aarav@example.com',
            password: 'wrong',
          );

      final state = container.read(authProvider);
      expect(succeeded, isFalse);
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.user, isNull);
      expect(state.failure?.message, 'Invalid email or password.');
      expect(state.isSubmitting, isFalse);
    });

    test('exposes 422 field errors for inline form messages', () async {
      when(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const Result.failure(
          ValidationFailure(
            'Validation failed.',
            errors: [
              FieldError(field: 'email', message: 'Enter a valid email.'),
            ],
          ),
        ),
      );
      final container = makeContainer();

      await container
          .read(authProvider.notifier)
          .login(email: 'nope', password: 'x');

      expect(
        container.read(authProvider).validationFailure?.forField('email'),
        'Enter a valid email.',
      );
    });

    test('clearFailure drops a stale error so a reopened form is clean',
        () async {
      when(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const Result.failure(UnauthorizedFailure()),
      );
      final container = makeContainer();
      final notifier = container.read(authProvider.notifier);
      await notifier.login(email: 'a@b.com', password: 'x');

      notifier.clearFailure();

      expect(container.read(authProvider).failure, isNull);
    });
  });

  group('register', () {
    test('signs the new account straight in', () async {
      when(
        () => repository.register(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
          phone: any(named: 'phone'),
        ),
      ).thenAnswer((_) async => const Result.success(serverUser));
      final container = makeContainer();

      final succeeded = await container.read(authProvider.notifier).register(
            name: 'Aarav Sharma',
            email: 'aarav@example.com',
            password: 'Str0ngPass',
          );

      expect(succeeded, isTrue);
      expect(container.read(authProvider).isAuthenticated, isTrue);
    });
  });

  group('session expiry', () {
    test('a 401 raised anywhere in the app ends the session', () async {
      final container = await signedIn();

      sessionExpired.add(null);
      await pumpEventQueue();

      final state = container.read(authProvider);
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.failure, isA<UnauthorizedFailure>());
    });
  });

  group('logout', () {
    test('always ends up signed out locally', () async {
      final container = await signedIn();
      when(() => repository.logout())
          .thenAnswer((_) async => const Result.success(null));

      await container.read(authProvider.notifier).logout();

      expect(container.read(authProvider).status, AuthStatus.unauthenticated);
      expect(container.read(authProvider).isSubmitting, isFalse);
      verify(() => repository.logout()).called(1);
    });

    test('logoutEverywhere keeps the session when the server refused',
        () async {
      final container = await signedIn();
      when(() => repository.logoutAll())
          .thenAnswer((_) async => const Result.failure(NetworkFailure()));

      final failure =
          await container.read(authProvider.notifier).logoutEverywhere();

      // Reporting "signed out everywhere" without the server having processed
      // it would leave the other devices logged in and the user believing
      // otherwise.
      expect(failure, isA<NetworkFailure>());
      expect(container.read(authProvider).status, AuthStatus.authenticated);
      expect(container.read(authProvider).isSubmitting, isFalse);
    });

    test('logoutEverywhere signs out when it landed', () async {
      final container = await signedIn();
      when(() => repository.logoutAll())
          .thenAnswer((_) async => const Result.success(null));

      final failure =
          await container.read(authProvider.notifier).logoutEverywhere();

      expect(failure, isNull);
      expect(container.read(authProvider).status, AuthStatus.unauthenticated);
    });
  });

  group('verifyEmail', () {
    test('promotes the live session', () async {
      final container = await signedIn();
      const verified = User(
        id: 'u1',
        name: 'Aarav Sharma',
        email: 'aarav@example.com',
        isEmailVerified: true,
      );
      when(() => repository.verifyEmail('token-123'))
          .thenAnswer((_) async => const Result.success(verified));

      final failure =
          await container.read(authProvider.notifier).verifyEmail('token-123');

      expect(failure, isNull);
      expect(container.read(authProvider).user?.canCheckout, isTrue);
    });

    test('does not sign anyone in when the link is opened while signed out',
        () async {
      final container = makeContainer();
      container.read(authProvider);
      when(() => repository.verifyEmail(any()))
          .thenAnswer((_) async => const Result.success(serverUser));

      await container.read(authProvider.notifier).verifyEmail('token-123');

      // Verifying is all the link does — a token in an email is not a
      // credential.
      expect(container.read(authProvider).status, AuthStatus.unauthenticated);
    });
  });

  group('resetPassword', () {
    test('signs the current device out on success', () async {
      final container = await signedIn();
      when(
        () => repository.resetPassword(
          token: any(named: 'token'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Result.success('Password updated.'));

      final result = await container.read(authProvider.notifier).resetPassword(
            token: 'reset-token',
            password: 'Str0ngerPass1',
          );

      // The reset bumped `tokenVersion`, so this session died with the others.
      expect(result.valueOrNull, 'Password updated.');
      expect(container.read(authProvider).status, AuthStatus.unauthenticated);
    });

    test('leaves the session alone when the token was refused', () async {
      final container = await signedIn();
      when(
        () => repository.resetPassword(
          token: any(named: 'token'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const Result.failure(
          ValidationFailure('This reset link has expired.'),
        ),
      );

      await container.read(authProvider.notifier).resetPassword(
            token: 'stale',
            password: 'Str0ngerPass1',
          );

      expect(container.read(authProvider).status, AuthStatus.authenticated);
    });
  });

  group('derived providers', () {
    test('currentUser and isAuthenticated follow the session', () async {
      final container = await signedIn();

      expect(container.read(currentUserProvider), serverUser);
      expect(container.read(isAuthenticatedProvider), isTrue);

      when(() => repository.logout())
          .thenAnswer((_) async => const Result.success(null));
      await container.read(authProvider.notifier).logout();

      expect(container.read(currentUserProvider), isNull);
      expect(container.read(isAuthenticatedProvider), isFalse);
    });
  });
}
