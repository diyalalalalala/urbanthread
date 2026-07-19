import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

/// Places the order.
///
/// The whole of checkout collapses into this one call — there is no gateway
/// hop, no redirect and nothing to resume. Whatever comes back is final: an
/// [Order] that is already settled, or a failure meaning no order was created
/// at all.
class PlaceOrderUseCase extends UseCase<Order, PlaceOrderDraft> {
  const PlaceOrderUseCase(this._repository);

  final OrderRepository _repository;

  @override
  Future<Result<Order>> call(PlaceOrderDraft params) =>
      _repository.placeOrder(params);
}
