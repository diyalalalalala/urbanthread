import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/cart_validation.dart';
import '../repositories/cart_repository.dart';

class ValidateCartUseCase extends UseCase<CartValidation, NoParams> {
  const ValidateCartUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<CartValidation>> call(NoParams params) =>
      _repository.validate();
}
