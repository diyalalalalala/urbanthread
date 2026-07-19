import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/recently_viewed_item.dart';
import '../providers/recently_viewed_notifier.dart';
import '../widgets/failure_from_error.dart';
import '../widgets/rating_stars.dart';

/// The last 20 products the customer opened.
class RecentlyViewedPage extends ConsumerWidget {
  const RecentlyViewedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recentlyViewedProvider);
    final hasItems = state.value?.isNotEmpty ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recently viewed'),
        actions: [
          if (hasItems)
            TextButton(
              onPressed: () => _confirmClear(context, ref),
              child: const Text('CLEAR'),
            ),
        ],
      ),
      body: switch (state) {
        AsyncData(:final value) when value.isEmpty => EmptyView(
            title: 'Nothing here yet',
            message: 'Products you open will be listed here so you can find '
                'them again.',
            icon: Icons.history,
            actionLabel: 'Start browsing',
            onAction: () => context.push(AppRoutes.products),
          ),
        AsyncData(:final value) => RefreshIndicator(
            onRefresh: () => ref.read(recentlyViewedProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppDimens.pageGutter),
              itemCount: value.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppDimens.space12),
              itemBuilder: (context, index) => _RecentTile(item: value[index]),
            ),
          ),
        AsyncError(:final error) => FailureView(
            failure: failureFrom(error),
            onRetry: () => ref.invalidate(recentlyViewedProvider),
          ),
        _ => const LoadingView(),
      },
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear recently viewed?'),
        content: const Text(
          'This only removes the history — nothing is deleted from your cart '
          'or wishlist.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: dialogContext.palette.danger,
            ),
            child: const Text('CLEAR'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final failure = await ref.read(recentlyViewedProvider.notifier).clear();
    if (!context.mounted) return;

    context.showSnack(
      failure?.message ?? 'History cleared.',
      isError: failure != null,
    );
  }
}

class _RecentTile extends StatelessWidget {
  const _RecentTile({required this.item});

  final RecentlyViewedItem item;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final product = item.product;

    return InkWell(
      // Detail is slug-only; the id carried alongside it would 404 here.
      onTap: () => context.push(AppRoutes.productDetailPath(product.slug)),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.space12),
        decoration: BoxDecoration(
          border: Border.all(color: palette.line),
          borderRadius: AppDimens.borderRadius,
        ),
        child: Row(
          children: [
            AppNetworkImage(
              url: product.imageUrl,
              width: 64,
              height: 84,
              borderRadius: AppDimens.borderRadiusSm,
            ),
            const SizedBox(width: AppDimens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: context.text.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimens.space4),
                  Row(
                    children: [
                      Text(
                        Formatters.price(product.displayPrice),
                        style: context.text.titleSmall,
                      ),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: AppDimens.space8),
                        Text(
                          Formatters.price(product.price),
                          style: context.text.bodySmall?.copyWith(
                            color: palette.inkSubtle,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (product.ratingCount > 0) ...[
                    const SizedBox(height: AppDimens.space4),
                    Row(
                      children: [
                        RatingStars(rating: product.ratingAverage, size: 14),
                        const SizedBox(width: AppDimens.space4),
                        Text(
                          '(${Formatters.compact(product.ratingCount)})',
                          style: context.text.bodySmall?.copyWith(
                            color: palette.inkSubtle,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppDimens.space4),
                  Row(
                    children: [
                      if (product.isOutOfStock) ...[
                        Text(
                          'OUT OF STOCK',
                          style: context.text.labelSmall?.copyWith(
                            color: palette.danger,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(width: AppDimens.space8),
                      ],
                      Text(
                        'Viewed ${Formatters.relative(item.viewedAt)}',
                        style: context.text.bodySmall?.copyWith(
                          color: palette.inkSubtle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
