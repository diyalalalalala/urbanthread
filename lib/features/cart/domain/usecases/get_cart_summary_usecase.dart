import '../../../../core/domain/result.dart';
import '../../../../core/domain/usecase.dart';
import '../entities/cart_summary.dart';
import '../repositories/cart_repository.dart';

/// Totals without the lines.
///
/// `GET /cart/summary` returns the summary object *alone* — not wrapped in the
/// `{cart, notices, summary}` triple the other cart routes use — so this is
/// the cheap read for a screen that only needs a payable total.
class GetCartSummaryUseCase extends UseCase<CartSummary, NoParams> {
  const GetCartSummaryUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<CartSummary>> call(NoParams params) => _repository.getSummary();
}
