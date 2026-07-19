import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

/// Asks to send some or all of a delivered order back.
///
/// Partial returns are the norm — the ids are per-line, so a customer can
/// return one garment of four and keep the rest.
class RequestReturnUseCase extends UseCase<Order, ReturnRequest> {
  const RequestReturnUseCase(this._repository);

  final OrderRepository _repository;

  @override
  Future<Result<Order>> call(ReturnRequest params) =>
      _repository.requestReturn(params);
}
