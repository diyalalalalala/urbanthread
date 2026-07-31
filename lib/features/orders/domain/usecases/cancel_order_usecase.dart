import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

class CancelOrderParams {
  const CancelOrderParams({required this.orderId, this.reason});

  final String orderId;

  final String? reason;
}

class CancelOrderUseCase extends UseCase<Order, CancelOrderParams> {
  const CancelOrderUseCase(this._repository);

  final OrderRepository _repository;

  @override
  Future<Result<Order>> call(CancelOrderParams params) =>
      _repository.cancelOrder(id: params.orderId, reason: params.reason);
}
