import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

class GetOrderByNumberUseCase extends UseCase<Order, String> {
  const GetOrderByNumberUseCase(this._repository);

  final OrderRepository _repository;

  @override
  Future<Result<Order>> call(String params) =>
      _repository.getOrderByNumber(params);
}
