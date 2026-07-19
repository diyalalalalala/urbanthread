import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

/// The tracking projection: status, timeline and courier details, with no
/// prices and no address.
class TrackOrderUseCase extends UseCase<OrderTracking, String> {
  const TrackOrderUseCase(this._repository);

  final OrderRepository _repository;

  @override
  Future<Result<OrderTracking>> call(String params) =>
      _repository.trackOrder(params);
}
