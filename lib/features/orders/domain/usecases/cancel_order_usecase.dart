import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

class CancelOrderParams {
  const CancelOrderParams({required this.orderId, this.reason});

  final String orderId;

  /// Optional, up to 300 characters.
  final String? reason;
}

/// Cancels the customer's own order.
///
/// Self-service cancellation closes once the order is packed, so this is a
/// 422 from `packed` onwards. Callers should gate the button on
/// [Order.isCancellable] rather than relying on the error.
class CancelOrderUseCase extends UseCase<Order, CancelOrderParams> {
  const CancelOrderUseCase(this._repository);

  final OrderRepository _repository;

  @override
  Future<Result<Order>> call(CancelOrderParams params) =>
      _repository.cancelOrder(id: params.orderId, reason: params.reason);
}
