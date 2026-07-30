// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_wishlist_save.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A save that was asked for while signed out, held until the sign-in returns.
///
/// The whole `/wishlist` API sits behind `authenticate`, so tapping the heart
/// as a guest cannot do anything on its own. Sending the customer to log in
/// and then dropping what they asked for is the sort of thing that reads as
/// the button being broken, so the product id is parked here and replayed on
/// the way back.
///
/// It has to survive the trip, and the trip is destructive: the login screen
/// finishes with `context.go(redirect)`, which replaces the navigation stack —
/// the product page that comes back is a *new* widget with no memory of the
/// tap. So this is deliberately kept outside the page, and `keepAlive` because
/// an auto-disposed provider would be collected during the detour and take the
/// intent with it.
///
/// Holds one id, not a queue: this exists to carry a single tap across one
/// redirect, and a guest cannot accumulate more than that.

@ProviderFor(PendingWishlistSave)
final pendingWishlistSaveProvider = PendingWishlistSaveProvider._();

/// A save that was asked for while signed out, held until the sign-in returns.
///
/// The whole `/wishlist` API sits behind `authenticate`, so tapping the heart
/// as a guest cannot do anything on its own. Sending the customer to log in
/// and then dropping what they asked for is the sort of thing that reads as
/// the button being broken, so the product id is parked here and replayed on
/// the way back.
///
/// It has to survive the trip, and the trip is destructive: the login screen
/// finishes with `context.go(redirect)`, which replaces the navigation stack —
/// the product page that comes back is a *new* widget with no memory of the
/// tap. So this is deliberately kept outside the page, and `keepAlive` because
/// an auto-disposed provider would be collected during the detour and take the
/// intent with it.
///
/// Holds one id, not a queue: this exists to carry a single tap across one
/// redirect, and a guest cannot accumulate more than that.
final class PendingWishlistSaveProvider
    extends $NotifierProvider<PendingWishlistSave, String?> {
  /// A save that was asked for while signed out, held until the sign-in returns.
  ///
  /// The whole `/wishlist` API sits behind `authenticate`, so tapping the heart
  /// as a guest cannot do anything on its own. Sending the customer to log in
  /// and then dropping what they asked for is the sort of thing that reads as
  /// the button being broken, so the product id is parked here and replayed on
  /// the way back.
  ///
  /// It has to survive the trip, and the trip is destructive: the login screen
  /// finishes with `context.go(redirect)`, which replaces the navigation stack —
  /// the product page that comes back is a *new* widget with no memory of the
  /// tap. So this is deliberately kept outside the page, and `keepAlive` because
  /// an auto-disposed provider would be collected during the detour and take the
  /// intent with it.
  ///
  /// Holds one id, not a queue: this exists to carry a single tap across one
  /// redirect, and a guest cannot accumulate more than that.
  PendingWishlistSaveProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingWishlistSaveProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingWishlistSaveHash();

  @$internal
  @override
  PendingWishlistSave create() => PendingWishlistSave();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$pendingWishlistSaveHash() =>
    r'36b982316d616eb48ff8cc066875cd9d544878f3';

/// A save that was asked for while signed out, held until the sign-in returns.
///
/// The whole `/wishlist` API sits behind `authenticate`, so tapping the heart
/// as a guest cannot do anything on its own. Sending the customer to log in
/// and then dropping what they asked for is the sort of thing that reads as
/// the button being broken, so the product id is parked here and replayed on
/// the way back.
///
/// It has to survive the trip, and the trip is destructive: the login screen
/// finishes with `context.go(redirect)`, which replaces the navigation stack —
/// the product page that comes back is a *new* widget with no memory of the
/// tap. So this is deliberately kept outside the page, and `keepAlive` because
/// an auto-disposed provider would be collected during the detour and take the
/// intent with it.
///
/// Holds one id, not a queue: this exists to carry a single tap across one
/// redirect, and a guest cannot accumulate more than that.

abstract class _$PendingWishlistSave extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
