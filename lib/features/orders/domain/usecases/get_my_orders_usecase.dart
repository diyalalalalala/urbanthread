import '../../../../core/domain/paginated.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

/// One page of the customer's order history.
class GetMyOrdersUseCase extends UseCase<Paginated<Order>, OrderFilter> {
  const GetMyOrdersUseCase(this._repository);

  final OrderRepository _repository;

  @override
  Future<Result<Paginated<Order>>> call(OrderFilter params) =>
      _repository.getMyOrders(params);
}
