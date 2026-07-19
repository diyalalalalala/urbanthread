import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

/// Looks an order up by the reference printed on the confirmation,
/// `UT-YYYYMMDD-NNNN`. The backend validates that shape before querying, so a
/// malformed reference is a 422 rather than a 404.
class GetOrderByNumberUseCase extends UseCase<Order, String> {
  const GetOrderByNumberUseCase(this._repository);

  final OrderRepository _repository;

  @override
  Future<Result<Order>> call(String params) =>
      _repository.getOrderByNumber(params);
}
