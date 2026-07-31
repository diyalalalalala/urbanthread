// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_lifecycle_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(IsAppForeground)
final isAppForegroundProvider = IsAppForegroundProvider._();

final class IsAppForegroundProvider
    extends $NotifierProvider<IsAppForeground, bool> {
  IsAppForegroundProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isAppForegroundProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isAppForegroundHash();

  @$internal
  @override
  IsAppForeground create() => IsAppForeground();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isAppForegroundHash() => r'fcf5dc918b4ed62b0ea8af6cc75899991d772199';

abstract class _$IsAppForeground extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
