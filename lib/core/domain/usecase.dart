import 'result.dart';

abstract class UseCase<T, Params> {
  const UseCase();

  Future<Result<T>> call(Params params);
}

abstract class StreamUseCase<T, Params> {
  const StreamUseCase();

  Stream<T> call(Params params);
}

class NoParams {
  const NoParams();

  @override
  bool operator ==(Object other) => other is NoParams;

  @override
  int get hashCode => 0;
}
