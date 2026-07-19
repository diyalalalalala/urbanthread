import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/cart_snapshot.dart';
import '../repositories/cart_repository.dart';

/// Reads the cart, falling back to the cached copy when offline.
class GetCartUseCase extends UseCase<CartSnapshot, NoParams> {
  const GetCartUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<CartSnapshot>> call(NoParams params) => _repository.getCart();
}
