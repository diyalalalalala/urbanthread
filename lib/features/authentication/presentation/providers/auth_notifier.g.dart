// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The session, and the only thing allowed to change it.
///
/// Kept alive for the app's lifetime: the router watches it to guard routes,
/// so letting it dispose would sign the user out whenever no screen happened
/// to be listening.

@ProviderFor(AuthNotifier)
final authProvider = AuthNotifierProvider._();

/// The session, and the only thing allowed to change it.
///
/// Kept alive for the app's lifetime: the router watches it to guard routes,
/// so letting it dispose would sign the user out whenever no screen happened
/// to be listening.
final class AuthNotifierProvider
    extends $NotifierProvider<AuthNotifier, AuthState> {
  /// The session, and the only thing allowed to change it.
  ///
  /// Kept alive for the app's lifetime: the router watches it to guard routes,
  /// so letting it dispose would sign the user out whenever no screen happened
  /// to be listening.
  AuthNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authNotifierHash();

  @$internal
  @override
  AuthNotifier create() => AuthNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthState>(value),
    );
  }
}

String _$authNotifierHash() => r'e54833cb58b59f176bba7af4706381010e773f8c';

/// The session, and the only thing allowed to change it.
///
/// Kept alive for the app's lifetime: the router watches it to guard routes,
/// so letting it dispose would sign the user out whenever no screen happened
/// to be listening.

abstract class _$AuthNotifier extends $Notifier<AuthState> {
  AuthState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AuthState, AuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthState, AuthState>,
              AuthState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The signed-in user, or null. The common read for screens that only need
/// identity and not the whole auth state.

@ProviderFor(currentUser)
final currentUserProvider = CurrentUserProvider._();

/// The signed-in user, or null. The common read for screens that only need
/// identity and not the whole auth state.

final class CurrentUserProvider extends $FunctionalProvider<User?, User?, User?>
    with $Provider<User?> {
  /// The signed-in user, or null. The common read for screens that only need
  /// identity and not the whole auth state.
  CurrentUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserHash();

  @$internal
  @override
  $ProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  User? create(Ref ref) {
    return currentUser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(User? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<User?>(value),
    );
  }
}

String _$currentUserHash() => r'3b06546ff87c5d3be903f8473b815c804850cc5c';

@ProviderFor(isAuthenticated)
final isAuthenticatedProvider = IsAuthenticatedProvider._();

final class IsAuthenticatedProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  IsAuthenticatedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isAuthenticatedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isAuthenticatedHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isAuthenticated(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isAuthenticatedHash() => r'89bd3a92964e327f27a526b571e6288cf3ad4faa';
