import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/cart_snapshot.dart';
import '../repositories/cart_repository.dart';

/// Parks a line so it survives checkout without being ordered.
class SaveForLaterUseCase extends UseCase<CartSnapshot, String> {
  const SaveForLaterUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<CartSnapshot>> call(String itemId) =>
      _repository.saveForLater(itemId);
}
