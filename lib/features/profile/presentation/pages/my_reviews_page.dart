import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/review.dart';
import '../../domain/entities/reviewable_product.dart';
import '../providers/my_reviews_notifier.dart';
import '../widgets/failure_from_error.dart';
import '../widgets/review_card.dart';
import 'write_review_page.dart';

/// The customer's reviews, and the products still waiting for one.
///
/// Two tabs rather than two screens: "what have I said" and "what could I say"
/// are the same task from the customer's side, and keeping them adjacent makes
/// the empty state of one an invitation into the other.
class MyReviewsPage extends ConsumerWidget {
  const MyReviewsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('My reviews'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'WRITTEN'),
                Tab(text: 'TO REVIEW'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [_WrittenTab(), _ToReviewTab()],
          ),
        ),
      );
}

class _WrittenTab extends ConsumerStatefulWidget {
  const _WrittenTab();

  @override
  ConsumerState<_WrittenTab> createState() => _WrittenTabState();
}

class _WrittenTabState extends ConsumerState<_WrittenTab> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  /// Fetches the next page a screen's-worth before the end, so the list never
  /// visibly stalls at the bottom.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      ref.read(myReviewsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myReviewsProvider);

    return switch (state) {
      AsyncData(:final value) when value.reviews.isEmpty => EmptyView(
          title: 'No reviews yet',
          message: 'Once an order is delivered you can tell everyone what you '
              'thought of it.',
          icon: Icons.rate_review_outlined,
          actionLabel: 'Browse products',
          onAction: () => context.push(AppRoutes.products),
        ),
      AsyncData(:final value) => RefreshIndicator(
          onRefresh: () => ref.read(myReviewsProvider.notifier).refresh(),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppDimens.pageGutter),
            itemCount: value.reviews.items.length + (value.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= value.reviews.items.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppDimens.space16),
                  child: LoadingView(),
                );
              }

              final review = value.reviews.items[index];
              return ReviewCard(
                review: review,
                onOpenProduct: review.product == null
                    ? null
                    : () => context.push(
                          AppRoutes.productDetailPath(review.product!.slug),
                        ),
                onEdit: () => _edit(review),
                onDelete: () => _confirmDelete(review),
              );
            },
          ),
        ),
      AsyncError(:final error) => FailureView(
          failure: failureFrom(error),
          onRetry: () => ref.invalidate(myReviewsProvider),
        ),
      _ => const LoadingView(),
    };
  }

  Future<void> _edit(Review review) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => WriteReviewPage(
          productId: review.productId,
          productName: review.product?.name ?? 'Your review',
          imageUrl: review.product?.imageUrl,
          existingReview: review,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Review review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this review?'),
        content: const Text(
          'It will be removed from the product page straight away. You can '
          'write a new one afterwards.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('KEEP'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: dialogContext.palette.danger,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final failure =
        await ref.read(myReviewsProvider.notifier).deleteReview(review.id);
    if (!mounted) return;

    context.showSnack(
      failure?.message ?? 'Review deleted.',
      isError: failure != null,
    );
  }
}

class _ToReviewTab extends ConsumerWidget {
  const _ToReviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewableProductsProvider);

    return switch (state) {
      AsyncData(:final value) when value.isEmpty => const EmptyView(
          title: 'Nothing waiting',
          message: 'Delivered items you have not reviewed yet will show up '
              'here.',
          icon: Icons.check_circle_outline,
        ),
      AsyncData(:final value) => RefreshIndicator(
          onRefresh: () =>
              ref.read(reviewableProductsProvider.notifier).refresh(),
          child: ListView.separated(
            padding: const EdgeInsets.all(AppDimens.pageGutter),
            itemCount: value.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppDimens.space12),
            itemBuilder: (context, index) => _ReviewableTile(
              item: value[index],
              onTap: () => _write(context, ref, value[index]),
            ),
          ),
        ),
      AsyncError(:final error) => FailureView(
          failure: failureFrom(error),
          onRetry: () => ref.invalidate(reviewableProductsProvider),
        ),
      _ => const LoadingView(),
    };
  }

  Future<void> _write(
    BuildContext context,
    WidgetRef ref,
    ReviewableProduct item,
  ) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => WriteReviewPage(
          // `product` is the identity here — the aggregate projects `_id` out
          // entirely, so there is no other id to pass.
          productId: item.productId,
          productName: item.productName,
          imageUrl: item.imageUrl,
        ),
      ),
    );
  }
}

class _ReviewableTile extends StatelessWidget {
  const _ReviewableTile({required this.item, required this.onTap});

  final ReviewableProduct item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.space12),
        decoration: BoxDecoration(
          border: Border.all(color: palette.line),
          borderRadius: AppDimens.borderRadius,
        ),
        child: Row(
          children: [
            AppNetworkImage(
              url: item.imageUrl,
              width: 56,
              height: 72,
              borderRadius: AppDimens.borderRadiusSm,
            ),
            const SizedBox(width: AppDimens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.brandName.isNotEmpty)
                    Text(
                      item.brandName.toUpperCase(),
                      style: context.text.labelSmall?.copyWith(
                        color: palette.inkSubtle,
                        letterSpacing: 1,
                      ),
                    ),
                  Text(
                    item.productName,
                    style: context.text.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimens.space4),
                  Text(
                    'Delivered ${Formatters.date(item.deliveredAt)}'
                    '${item.orderNumber.isEmpty ? '' : ' · ${item.orderNumber}'}',
                    style: context.text.bodySmall?.copyWith(
                      color: palette.inkSubtle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimens.space8),
            Icon(Icons.star_outline_rounded, color: palette.accent),
          ],
        ),
      ),
    );
  }
}
