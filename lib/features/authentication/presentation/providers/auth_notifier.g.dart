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
  void runBuild() {
    final ref = this.ref as $Ref<AuthState, AuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthState, AuthState>,
              AuthState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// The signed-in user, or null. The common read for screens that need
/// identity but not the rest of the auth state.
///
/// These derive from the whole state rather than a `.select` on it —
/// [AuthState] is an Equatable value, so an unchanged state is already
/// filtered out, and a derived provider only re-emits when its own output
/// differs. The rebuild savings are the same without the ceremony.

@ProviderFor(currentUser)
final currentUserProvider = CurrentUserProvider._();

/// The signed-in user, or null. The common read for screens that need
/// identity but not the rest of the auth state.
///
/// These derive from the whole state rather than a `.select` on it —
/// [AuthState] is an Equatable value, so an unchanged state is already
/// filtered out, and a derived provider only re-emits when its own output
/// differs. The rebuild savings are the same without the ceremony.

final class CurrentUserProvider extends $FunctionalProvider<User?, User?, User?>
    with $Provider<User?> {
  /// The signed-in user, or null. The common read for screens that need
  /// identity but not the rest of the auth state.
  ///
  /// These derive from the whole state rather than a `.select` on it —
  /// [AuthState] is an Equatable value, so an unchanged state is already
  /// filtered out, and a derived provider only re-emits when its own output
  /// differs. The rebuild savings are the same without the ceremony.
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

String _$currentUserHash() => r'42a64e9add863646f8bc2629da227312483d55b7';

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

String _$isAuthenticatedHash() => r'9bda0a0cf39820eaa945f2a8b7ef36f5f4b8d690';
