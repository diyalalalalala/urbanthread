import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/cart_snapshot.dart';
import '../repositories/cart_repository.dart';

/// Flushes the offline write queue and reconciles with the server.
///
/// Triggered when connectivity returns, not by a user action — an offline
/// "add to cart" must reach the server eventually without the customer having
/// to remember it happened.
class SyncCartUseCase extends UseCase<CartSnapshot, NoParams> {
  const SyncCartUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<CartSnapshot>> call(NoParams params) =>
      _repository.syncPendingWrites();
}
