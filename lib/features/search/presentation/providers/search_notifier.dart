import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/domain/entities/product_query.dart';
import '../../../products/presentation/providers/product_providers.dart';
import 'search_providers.dart';

part 'search_notifier.g.dart';

class SearchState extends Equatable {
  const SearchState({
    this.term = '',
    this.results = const [],
    this.history = const [],
    this.isSearching = false,
    this.isLoadingMore = false,
    this.hasSearched = false,
    this.hasNextPage = false,
    this.total = 0,
    this.page = 1,
    this.failure,
  });

  final String term;
  final List<Product> results;

  final List<String> history;

  final bool isSearching;
  final bool isLoadingMore;

  final bool hasSearched;

  final bool hasNextPage;
  final int total;
  final int page;
  final Failure? failure;

  bool get isQueryable => term.trim().length >= 2;

  bool get showsHistory => !isQueryable && !isSearching;

  bool get isEmptyResult =>
      hasSearched && results.isEmpty && failure == null && !isSearching;

  SearchState copyWith({
    String? term,
    List<Product>? results,
    List<String>? history,
    bool? isSearching,
    bool? isLoadingMore,
    bool? hasSearched,
    bool? hasNextPage,
    int? total,
    int? page,
    Failure? failure,
    bool clearFailure = false,
  }) =>
      SearchState(
        term: term ?? this.term,
        results: results ?? this.results,
        history: history ?? this.history,
        isSearching: isSearching ?? this.isSearching,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasSearched: hasSearched ?? this.hasSearched,
        hasNextPage: hasNextPage ?? this.hasNextPage,
        total: total ?? this.total,
        page: page ?? this.page,
        failure: clearFailure ? null : (failure ?? this.failure),
      );

  @override
  List<Object?> get props => [
        term,
        results,
        history,
        isSearching,
        isLoadingMore,
        hasSearched,
        hasNextPage,
        total,
        page,
        failure,
      ];
}

@riverpod
class SearchNotifier extends _$SearchNotifier {
  static const debounceDuration = Duration(milliseconds: 350);

  Timer? _debounce;
  int _requestId = 0;

  @override
  SearchState build() {
    ref.onDispose(() => _debounce?.cancel());
    unawaited(_loadHistory());
    return const SearchState();
  }

  Future<void> _loadHistory() async {
    final result = await ref.read(getSearchHistoryUseCaseProvider)(
      const NoParams(),
    );
    if (result case Success(:final value)) {
      state = state.copyWith(history: value);
    }
  }

  void onTermChanged(String term) {
    _debounce?.cancel();
    state = state.copyWith(term: term, clearFailure: true);

    if (!state.isQueryable) {
      _requestId++;
      state = state.copyWith(
        results: const [],
        hasSearched: false,
        isSearching: false,
        hasNextPage: false,
        total: 0,
        page: 1,
      );
      return;
    }

    state = state.copyWith(isSearching: true);
    _debounce = Timer(debounceDuration, () => unawaited(_search(term)));
  }

  Future<void> submit([String? term]) async {
    _debounce?.cancel();
    final value = (term ?? state.term).trim();
    if (value.length < 2) return;

    state = state.copyWith(term: value, isSearching: true, clearFailure: true);
    await _search(value, recordInHistory: true);
  }

  Future<void> _search(String term, {bool recordInHistory = false}) async {
    final requestId = ++_requestId;

    final result = await ref.read(searchProductsUseCaseProvider)(
      ProductQuery(search: term),
    );

    if (requestId != _requestId) return;

    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          results: value.items,
          total: value.total,
          hasNextPage: value.hasNextPage,
          page: 1,
          isSearching: false,
          hasSearched: true,
          clearFailure: true,
        );
        if (recordInHistory && value.items.isNotEmpty) {
          await _record(term);
        }
      case FailureResult(:final failure):
        state = state.copyWith(
          isSearching: false,
          hasSearched: true,
          results: const [],
          failure: failure,
        );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasNextPage || state.isSearching) return;

    state = state.copyWith(isLoadingMore: true);
    final requestId = _requestId;
    final nextPage = state.page + 1;

    final result = await ref.read(searchProductsUseCaseProvider)(
      ProductQuery(search: state.term.trim(), page: nextPage),
    );

    if (requestId != _requestId) return;

    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          results: [...state.results, ...value.items],
          hasNextPage: value.hasNextPage,
          total: value.total,
          page: nextPage,
          isLoadingMore: false,
        );
      case FailureResult(:final failure):
        state = state.copyWith(isLoadingMore: false, failure: failure);
    }
  }

  Future<void> _record(String term) async {
    final result = await ref.read(addSearchTermUseCaseProvider)(term);
    if (result case Success(:final value)) {
      state = state.copyWith(history: value);
    }
  }

  Future<void> removeHistoryTerm(String term) async {
    final result = await ref.read(removeSearchTermUseCaseProvider)(term);
    if (result case Success(:final value)) {
      state = state.copyWith(history: value);
    }
  }

  Future<void> clearHistory() async {
    final result = await ref.read(clearSearchHistoryUseCaseProvider)(
      const NoParams(),
    );
    if (result case Success(:final value)) {
      state = state.copyWith(history: value);
    }
  }

  void clear() {
    _debounce?.cancel();
    _requestId++;
    state = SearchState(history: state.history);
  }

  Future<void> retry() => submit();
}
