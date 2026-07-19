import 'result.dart';

/// A single application action, invoked as if it were a function.
///
/// Use cases are the only thing presentation is allowed to call, which keeps
/// notifiers free of orchestration: "add to cart then refresh the badge"
/// lives in a use case, not in a widget's callback.
abstract class UseCase<T, Params> {
  const UseCase();

  Future<Result<T>> call(Params params);
}

/// A use case that streams, for anything continuously observed — the cart
/// badge, unread notification count, connectivity.
abstract class StreamUseCase<T, Params> {
  const StreamUseCase();

  Stream<T> call(Params params);
}

/// Parameter type for a use case that takes no arguments.
///
/// `const NoParams()` beats a nullable parameter: the call site reads the
/// same for every use case, so they stay interchangeable.
class NoParams {
  const NoParams();

  @override
  bool operator ==(Object other) => other is NoParams;

  @override
  int get hashCode => 0;
}
