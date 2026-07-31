import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

class GetOrderByIdUseCase extends UseCase<Order, String> {
  const GetOrderByIdUseCase(this._repository);

  final OrderRepository _repository;

  @override
  Future<Result<Order>> call(String params) => _repository.getOrderById(params);
}
