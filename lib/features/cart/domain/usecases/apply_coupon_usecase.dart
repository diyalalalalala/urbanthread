import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/cart_snapshot.dart';
import '../repositories/cart_repository.dart';

class ApplyCouponUseCase extends UseCase<CartSnapshot, String> {
  const ApplyCouponUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<CartSnapshot>> call(String code) =>
      _repository.applyCoupon(code);
}
