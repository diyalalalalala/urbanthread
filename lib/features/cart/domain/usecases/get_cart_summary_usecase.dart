import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/cart_summary.dart';
import '../repositories/cart_repository.dart';

class GetCartSummaryUseCase extends UseCase<CartSummary, NoParams> {
  const GetCartSummaryUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<CartSummary>> call(NoParams params) => _repository.getSummary();
}
