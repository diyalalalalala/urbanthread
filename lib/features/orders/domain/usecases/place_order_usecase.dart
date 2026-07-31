import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

class PlaceOrderUseCase extends UseCase<Order, PlaceOrderDraft> {
  const PlaceOrderUseCase(this._repository);

  final OrderRepository _repository;

  @override
  Future<Result<Order>> call(PlaceOrderDraft params) =>
      _repository.placeOrder(params);
}
