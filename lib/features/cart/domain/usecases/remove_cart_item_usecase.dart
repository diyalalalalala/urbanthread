import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/cart_snapshot.dart';
import '../repositories/cart_repository.dart';

class RemoveCartItemUseCase extends UseCase<CartSnapshot, String> {
  const RemoveCartItemUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<CartSnapshot>> call(String itemId) =>
      _repository.removeItem(itemId);
}
