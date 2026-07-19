import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../products/presentation/widgets/product_grid.dart';
import '../providers/search_notifier.dart';
import '../widgets/search_field.dart';
import '../widgets/search_history_list.dart';

/// The search screen.
///
/// Reuses the catalogue's `ProductCard` through [SliverProductGrid], so a
/// result tile is identical to one in the browse grid — a shopper should not
/// have to re-learn the card because they arrived at it a different way.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key, this.initialTerm});

  /// Prefills the box, for arriving from a "search for X" link.
  final String? initialTerm;

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialTerm ?? '');
  final _scrollController = ScrollController();

  static const _loadMoreThreshold = 600.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    final initial = widget.initialTerm?.trim();
    if (initial != null && initial.isNotEmpty) {
      // After the first frame: the notifier is not safe to mutate while the
      // widget tree is still being built.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(searchProvider.notifier).submit(initial);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      ref.read(searchProvider.notifier).loadMore();
    }
  }

  SearchNotifier get _notifier => ref.read(searchProvider.notifier);

  void _runTerm(String term) {
    _controller
      ..text = term
      ..selection = TextSelection.collapsed(offset: term.length);
    _notifier.submit(term);
    // The shopper picked a term rather than typing one, so get the keyboard
    // out of the way of the results.
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: AppDimens.space16),
          child: SearchField(
            controller: _controller,
            onChanged: _notifier.onTermChanged,
            onSubmitted: (term) {
              _notifier.submit(term);
              FocusScope.of(context).unfocus();
            },
            onCleared: _notifier.clear,
          ),
        ),
      ),
      body: _body(state),
    );
  }

  Widget _body(SearchState state) {
    if (state.showsHistory) {
      return state.history.isEmpty
          ? const EmptyView(
              title: 'Find something you love',
              message: 'Search by product, brand, colour or size.',
              icon: Icons.search,
            )
          : SearchHistoryList(
              terms: state.history,
              onTermSelected: _runTerm,
              onTermRemoved: _notifier.removeHistoryTerm,
              onCleared: _notifier.clearHistory,
            );
    }

    if (state.isSearching && state.results.isEmpty) {
      return const LoadingView(message: 'Searching…');
    }

    final failure = state.failure;
    if (failure != null && state.results.isEmpty) {
      return FailureView(failure: failure, onRetry: _notifier.retry);
    }

    if (state.isEmptyResult) {
      return EmptyView(
        title: 'No matches',
        message: 'Nothing matched “${state.term.trim()}”. '
            'Try a shorter or more general term.',
        icon: Icons.search_off,
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      // Dismiss the keyboard as soon as the shopper starts browsing results.
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.pageGutter,
              AppDimens.space12,
              AppDimens.pageGutter,
              AppDimens.space4,
            ),
            child: Text(
              '${state.total} ${state.total == 1 ? 'RESULT' : 'RESULTS'}',
              style: AppTypography.eyebrow.copyWith(
                color: context.palette.inkSubtle,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.pageGutter,
            AppDimens.space12,
            AppDimens.pageGutter,
            AppDimens.space16,
          ),
          sliver: SliverProductGrid(products: state.results),
        ),
        SliverToBoxAdapter(
          child: state.isLoadingMore
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppDimens.space24),
                  child: LoadingView(),
                )
              : const SizedBox(height: AppDimens.space32),
        ),
      ],
    );
  }
}
