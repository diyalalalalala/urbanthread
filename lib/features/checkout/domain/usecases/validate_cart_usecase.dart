import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/checkout_cart.dart';
import '../repositories/checkout_repository.dart';

class ValidateCartUseCase extends UseCase<CheckoutCart, NoParams> {
  const ValidateCartUseCase(this._repository);

  final CheckoutRepository _repository;

  @override
  Future<Result<CheckoutCart>> call(NoParams params) =>
      _repository.validateCart();
}
