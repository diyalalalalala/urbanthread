import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/order.dart';
import '../providers/orders_notifier.dart';
import '../widgets/order_card.dart';
import '../widgets/order_pricing_summary.dart';

/// Pick the items to send back and say why.
///
/// Returns are per line, not per order — the API takes an array of
/// **order-item** ids, so a customer can keep three of four garments. Items
/// already requested, approved or refunded are not offered again; only a
/// previously rejected one may be re-submitted.
class ReturnRequestPage extends ConsumerStatefulWidget {
  const ReturnRequestPage({required this.order, super.key});

  final Order order;

  @override
  ConsumerState<ReturnRequestPage> createState() => _ReturnRequestPageState();
}

class _ReturnRequestPageState extends ConsumerState<ReturnRequestPage> {
  static const _minReasonLength = 5;
  static const _maxReasonLength = 300;

  final _selected = <String>{};
  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Re-validate the submit button as the reason is typed.
    _reasonController.addListener(_onReasonChanged);

    final returnable = widget.order.returnableItems;
    // With a single eligible item there is no choice to make, so pre-select
    // it rather than making the customer tick a list of one.
    if (returnable.length == 1) _selected.add(returnable.first.id);
  }

  @override
  void dispose() {
    _reasonController
      ..removeListener(_onReasonChanged)
      ..dispose();
    super.dispose();
  }

  void _onReasonChanged() => setState(() {});

  String get _reason => _reasonController.text.trim();

  bool get _canSubmit =>
      _selected.isNotEmpty && _reason.length >= _minReasonLength;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final returnable = order.returnableItems;
    final state = ref.watch(orderDetailProvider(order.id));
    final daysLeft = order.returnWindowDaysRemaining;

    return Scaffold(
      backgroundColor: context.palette.canvas,
      appBar: AppBar(title: const Text('Request a return')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimens.pageGutter,
          AppDimens.space16,
          AppDimens.pageGutter,
          AppDimens.space32,
        ),
        children: [
          Text(order.orderNumber, style: context.text.titleMedium),
          const SizedBox(height: AppDimens.space4),
          Text(
            'Delivered ${Formatters.date(order.deliveredAt)}'
            '${daysLeft == null ? '' : ' · $daysLeft '
                '${daysLeft == 1 ? 'day' : 'days'} left'}',
            style: context.text.bodySmall,
          ),
          const SizedBox(height: AppDimens.space24),

          const OrderSectionHeader(title: 'Which items?'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.space12),
            decoration: BoxDecoration(
              color: context.palette.surface,
              border: Border.all(color: context.palette.line),
              borderRadius: AppDimens.borderRadius,
            ),
            child: Column(
              children: [
                for (var index = 0; index < returnable.length; index += 1) ...[
                  if (index > 0)
                    Divider(height: 1, color: context.palette.line),
                  _SelectableItem(
                    item: returnable[index],
                    isSelected: _selected.contains(returnable[index].id),
                    onToggle: () => _toggle(returnable[index].id),
                  ),
                ],
              ],
            ),
          ),

          // Lines that cannot be re-requested are still listed, greyed, so the
          // customer can see the app has not simply lost them.
          if (returnable.length != order.items.length) ...[
            const SizedBox(height: AppDimens.space24),
            const OrderSectionHeader(title: 'Not eligible'),
            for (final item in order.items.where((i) => !i.isReturnable))
              Opacity(opacity: 0.55, child: OrderItemTile(item: item)),
          ],

          const SizedBox(height: AppDimens.space24),
          const OrderSectionHeader(title: 'Why are you returning these?'),
          TextField(
            controller: _reasonController,
            maxLines: 4,
            maxLength: _maxReasonLength,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Too small, arrived damaged, not as described…',
              // The backend requires 5–300 characters: a return is judged by a
              // person, and an unexplained request cannot be assessed.
              errorText: _reason.isNotEmpty && _reason.length < _minReasonLength
                  ? 'Please give us a little more detail.'
                  : null,
            ),
          ),
          const SizedBox(height: AppDimens.space24),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _canSubmit && !state.isSubmitting ? _submit : null,
              child: Text(
                state.isSubmitting
                    ? 'SENDING…'
                    : 'REQUEST RETURN'
                        '${_selected.isEmpty ? '' : ' (${_selected.length})'}',
              ),
            ),
          ),
          const SizedBox(height: AppDimens.space12),
          Text(
            'We review every request by hand. You will hear back once it has '
            'been looked at — the items stay yours until then.',
            style: context.text.bodySmall,
          ),
        ],
      ),
    );
  }

  void _toggle(String itemId) => setState(() {
        if (!_selected.remove(itemId)) _selected.add(itemId);
      });

  Future<void> _submit() async {
    final ok = await ref
        .read(orderDetailProvider(widget.order.id).notifier)
        .requestReturn(itemIds: _selected.toList(), reason: _reason);

    if (!mounted) return;

    if (ok) {
      // Popping back to the detail screen, which the notifier has already
      // updated with the server's copy of the order — its per-item return
      // badges are live the moment this page leaves.
      Navigator.of(context).pop();
      context.showSnack('Return requested. We will be in touch.');
    }
    // A refusal surfaces through the detail page's own listener, so nothing
    // more to do here — and the page stays open with the selection intact.
  }
}

class _SelectableItem extends StatelessWidget {
  const _SelectableItem({
    required this.item,
    required this.isSelected,
    required this.onToggle,
  });

  final OrderItem item;
  final bool isSelected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onToggle,
        child: OrderItemTile(
          item: item,
          trailing: Checkbox(
            value: isSelected,
            onChanged: (_) => onToggle(),
          ),
        ),
      );
}
