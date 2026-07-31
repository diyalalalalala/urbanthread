// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_wishlist_save.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PendingWishlistSave)
final pendingWishlistSaveProvider = PendingWishlistSaveProvider._();

final class PendingWishlistSaveProvider
    extends $NotifierProvider<PendingWishlistSave, String?> {
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
