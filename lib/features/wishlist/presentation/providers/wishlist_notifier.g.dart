// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The wishlist, and the only thing allowed to change it.
///
/// Kept alive so the saved-items badge and every heart button in the app read
/// one source of truth. Removals are optimistic — the card leaves the grid on
/// tap and comes back if the server refuses — because a heart that waits on a
/// round trip before filling is the single most obvious lag in a storefront.

@ProviderFor(WishlistNotifier)
final wishlistProvider = WishlistNotifierProvider._();

/// The wishlist, and the only thing allowed to change it.
///
/// Kept alive so the saved-items badge and every heart button in the app read
/// one source of truth. Removals are optimistic — the card leaves the grid on
/// tap and comes back if the server refuses — because a heart that waits on a
/// round trip before filling is the single most obvious lag in a storefront.
final class WishlistNotifierProvider
    extends $NotifierProvider<WishlistNotifier, WishlistState> {
  /// The wishlist, and the only thing allowed to change it.
  ///
  /// Kept alive so the saved-items badge and every heart button in the app read
  /// one source of truth. Removals are optimistic — the card leaves the grid on
  /// tap and comes back if the server refuses — because a heart that waits on a
  /// round trip before filling is the single most obvious lag in a storefront.
  WishlistNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wishlistProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wishlistNotifierHash();

  @$internal
  @override
  WishlistNotifier create() => WishlistNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WishlistState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WishlistState>(value),
    );
  }
}

String _$wishlistNotifierHash() => r'ce4e1e7b5d5c23dc85664cc274a022275f9a660f';

/// The wishlist, and the only thing allowed to change it.
///
/// Kept alive so the saved-items badge and every heart button in the app read
/// one source of truth. Removals are optimistic — the card leaves the grid on
/// tap and comes back if the server refuses — because a heart that waits on a
/// round trip before filling is the single most obvious lag in a storefront.

abstract class _$WishlistNotifier extends $Notifier<WishlistState> {
  WishlistState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<WishlistState, WishlistState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WishlistState, WishlistState>,
              WishlistState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Saved-item count, for the bottom-nav badge.
///
/// Derived rather than `.select`-ed — `.select` is unavailable on a generated
/// notifier provider in Riverpod 3, and this only re-emits when the number
/// itself changes.

@ProviderFor(wishlistCount)
final wishlistCountProvider = WishlistCountProvider._();

/// Saved-item count, for the bottom-nav badge.
///
/// Derived rather than `.select`-ed — `.select` is unavailable on a generated
/// notifier provider in Riverpod 3, and this only re-emits when the number
/// itself changes.

final class WishlistCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Saved-item count, for the bottom-nav badge.
  ///
  /// Derived rather than `.select`-ed — `.select` is unavailable on a generated
  /// notifier provider in Riverpod 3, and this only re-emits when the number
  /// itself changes.
  WishlistCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wishlistCountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wishlistCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return wishlistCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$wishlistCountHash() => r'02d034f42058a3a88e247427a7a5231c93bff2e8';

/// Whether a product is saved, for a heart button anywhere in the app.
///
/// Answers from the loaded wishlist, which is kept alive and cached — so a
/// product card does not pay a `/wishlist/{id}/check` round trip per tile.

@ProviderFor(isWishlisted)
final isWishlistedProvider = IsWishlistedFamily._();

/// Whether a product is saved, for a heart button anywhere in the app.
///
/// Answers from the loaded wishlist, which is kept alive and cached — so a
/// product card does not pay a `/wishlist/{id}/check` round trip per tile.

final class IsWishlistedProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether a product is saved, for a heart button anywhere in the app.
  ///
  /// Answers from the loaded wishlist, which is kept alive and cached — so a
  /// product card does not pay a `/wishlist/{id}/check` round trip per tile.
  IsWishlistedProvider._({
    required IsWishlistedFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isWishlistedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isWishlistedHash();

  @override
  String toString() {
    return r'isWishlistedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as String;
    return isWishlisted(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsWishlistedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isWishlistedHash() => r'a54c460e392c5a5a4334a62f725e4fc8ab3395ad';

/// Whether a product is saved, for a heart button anywhere in the app.
///
/// Answers from the loaded wishlist, which is kept alive and cached — so a
/// product card does not pay a `/wishlist/{id}/check` round trip per tile.

final class IsWishlistedFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  IsWishlistedFamily._()
    : super(
        retry: null,
        name: r'isWishlistedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether a product is saved, for a heart button anywhere in the app.
  ///
  /// Answers from the loaded wishlist, which is kept alive and cached — so a
  /// product card does not pay a `/wishlist/{id}/check` round trip per tile.

  IsWishlistedProvider call(String productId) =>
      IsWishlistedProvider._(argument: productId, from: this);

  @override
  String toString() => r'isWishlistedProvider';
}
