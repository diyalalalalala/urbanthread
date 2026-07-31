import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

class RequestReturnUseCase extends UseCase<Order, ReturnRequest> {
  const RequestReturnUseCase(this._repository);

  final OrderRepository _repository;

  @override
  Future<Result<Order>> call(ReturnRequest params) =>
      _repository.requestReturn(params);
}
