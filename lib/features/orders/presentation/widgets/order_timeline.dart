import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/order.dart';
import 'order_status_chip.dart';

class OrderTimeline extends StatelessWidget {
  const OrderTimeline({required this.entries, super.key, this.currentStatus});

  final List<OrderTimelineEntry> entries;

  final OrderStatus? currentStatus;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Text(
        'No history recorded yet.',
        style: context.text.bodySmall,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < entries.length; index += 1)
          _TimelineRow(
            entry: entries[index],
            isFirst: index == 0,
            isLast: index == entries.length - 1,
            isCurrent: index == entries.length - 1 &&
                (currentStatus == null || entries[index].status == currentStatus),
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.entry,
    required this.isFirst,
    required this.isLast,
    required this.isCurrent,
  });

  final OrderTimelineEntry entry;
  final bool isFirst;
  final bool isLast;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final colors = orderStatusColors(context, entry.status);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 1,
                  height: AppDimens.space8,
                  color: isFirst ? Colors.transparent : palette.line,
                ),
                Container(
                  width: isCurrent ? 14 : 10,
                  height: isCurrent ? 14 : 10,
                  decoration: BoxDecoration(
                    color: colors.foreground,
                    shape: BoxShape.circle,
                    border: isCurrent
                        ? Border.all(color: colors.background, width: 3)
                        : null,
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 1,
                    color: isLast ? Colors.transparent : palette.line,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.space12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.space20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.status.label,
                    style: context.text.titleSmall?.copyWith(
                      color: isCurrent ? colors.foreground : palette.ink,
                    ),
                  ),
                  if (entry.note.isNotEmpty) ...[
                    const SizedBox(height: AppDimens.space2),
                    Text(entry.note, style: context.text.bodySmall),
                  ],
                  if (entry.occurredAt != null) ...[
                    const SizedBox(height: AppDimens.space4),
                    Text(
                      Formatters.dateTime(entry.occurredAt),
                      style: context.text.labelMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderProgressStepper extends StatelessWidget {
  const OrderProgressStepper({required this.status, super.key});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    if (status.isTerminal) {
      final colors = orderStatusColors(context, status);
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimens.space16),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: AppDimens.borderRadius,
        ),
        child: Row(
          children: [
            Icon(orderStatusIcon(status), color: colors.foreground, size: 20),
            const SizedBox(width: AppDimens.space12),
            Expanded(
              child: Text(
                status.description,
                style: context.text.bodyMedium?.copyWith(
                  color: colors.foreground,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final reached = OrderStatus.progression.indexOf(status);

    return Row(
      children: [
        for (var index = 0; index < OrderStatus.progression.length; index += 1)
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index == 0
                            ? Colors.transparent
                            : (index <= reached
                                ? palette.accent
                                : palette.line),
                      ),
                    ),
                    Icon(
                      index <= reached
                          ? Icons.circle
                          : Icons.circle_outlined,
                      size: index == reached ? 14 : 10,
                      color:
                          index <= reached ? palette.accent : palette.lineStrong,
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index == OrderStatus.progression.length - 1
                            ? Colors.transparent
                            : (index < reached
                                ? palette.accent
                                : palette.line),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.space8),
                Text(
                  OrderStatus.progression[index].label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: context.text.labelSmall?.copyWith(
                    fontSize: 9,
                    color: index <= reached
                        ? palette.ink
                        : palette.inkSubtle,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
