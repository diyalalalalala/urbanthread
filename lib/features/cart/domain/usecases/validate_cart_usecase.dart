import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/cart_validation.dart';
import '../repositories/cart_repository.dart';

/// The gate to run before opening checkout.
///
/// Reports every blocker at once so the customer fixes the cart in one pass
/// rather than discovering problems one refusal at a time. Note that any
/// outstanding reconciliation notice counts as blocking: if the cart changed
/// since it was last displayed, the customer must see the new state first.
class ValidateCartUseCase extends UseCase<CartValidation, NoParams> {
  const ValidateCartUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<CartValidation>> call(NoParams params) =>
      _repository.validate();
}
