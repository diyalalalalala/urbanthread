// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The search screen's state, debounced.
///
/// Two mechanisms guard against a fast typist, and both are needed. The
/// [_debounce] timer stops a request being sent per keystroke; the
/// [_requestId] generation counter discards a response that arrives *after* a
/// later one, which the timer cannot prevent — an early short query can take
/// longer to run than the longer query that superseded it, and without the
/// counter the screen would settle on results for a term the user has already
/// finished typing over.

@ProviderFor(SearchNotifier)
final searchProvider = SearchNotifierProvider._();

/// The search screen's state, debounced.
///
/// Two mechanisms guard against a fast typist, and both are needed. The
/// [_debounce] timer stops a request being sent per keystroke; the
/// [_requestId] generation counter discards a response that arrives *after* a
/// later one, which the timer cannot prevent — an early short query can take
/// longer to run than the longer query that superseded it, and without the
/// counter the screen would settle on results for a term the user has already
/// finished typing over.
final class SearchNotifierProvider
    extends $NotifierProvider<SearchNotifier, SearchState> {
  /// The search screen's state, debounced.
  ///
  /// Two mechanisms guard against a fast typist, and both are needed. The
  /// [_debounce] timer stops a request being sent per keystroke; the
  /// [_requestId] generation counter discards a response that arrives *after* a
  /// later one, which the timer cannot prevent — an early short query can take
  /// longer to run than the longer query that superseded it, and without the
  /// counter the screen would settle on results for a term the user has already
  /// finished typing over.
  SearchNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchNotifierHash();

  @$internal
  @override
  SearchNotifier create() => SearchNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchState>(value),
    );
  }
}

String _$searchNotifierHash() => r'f054d75a2d4c2c333102adb1b20bef66c7ebcfa3';

/// The search screen's state, debounced.
///
/// Two mechanisms guard against a fast typist, and both are needed. The
/// [_debounce] timer stops a request being sent per keystroke; the
/// [_requestId] generation counter discards a response that arrives *after* a
/// later one, which the timer cannot prevent — an early short query can take
/// longer to run than the longer query that superseded it, and without the
/// counter the screen would settle on results for a term the user has already
/// finished typing over.

abstract class _$SearchNotifier extends $Notifier<SearchState> {
  SearchState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SearchState, SearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchState, SearchState>,
              SearchState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
