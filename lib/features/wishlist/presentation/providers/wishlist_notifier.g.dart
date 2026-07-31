// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WishlistNotifier)
final wishlistProvider = WishlistNotifierProvider._();

final class WishlistNotifierProvider
    extends $NotifierProvider<WishlistNotifier, WishlistState> {
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

String _$wishlistNotifierHash() => r'e1cb71f2f6d19d964ed0da46c7cf5ee3328dfaba';

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

@ProviderFor(wishlistCount)
final wishlistCountProvider = WishlistCountProvider._();

final class WishlistCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
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

@ProviderFor(isWishlisted)
final isWishlistedProvider = IsWishlistedFamily._();

final class IsWishlistedProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
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

  IsWishlistedProvider call(String productId) =>
      IsWishlistedProvider._(argument: productId, from: this);

  @override
  String toString() => r'isWishlistedProvider';
}
