import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/cart_snapshot.dart';
import '../repositories/cart_repository.dart';

class GetCartUseCase extends UseCase<CartSnapshot, NoParams> {
  const GetCartUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<CartSnapshot>> call(NoParams params) => _repository.getCart();
}
