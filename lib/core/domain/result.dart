import '../errors/failures.dart';

/// The outcome of an operation that is allowed to fail: either a value or a
/// [Failure].
///
/// Repositories return this instead of throwing, so a use case cannot forget
/// to handle an error — the type will not let it reach the value without
/// deciding what a failure means first. Sealed, so `switch` is exhaustive.
sealed class Result<T> {
  const Result();

  const factory Result.success(T value) = Success<T>;
  const factory Result.failure(Failure failure) = FailureResult<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;

  /// The value, or null when this is a failure.
  T? get valueOrNull => switch (this) {
        Success<T>(:final value) => value,
        FailureResult<T>() => null,
      };

  /// The failure, or null when this is a success.
  Failure? get failureOrNull => switch (this) {
        Success<T>() => null,
        FailureResult<T>(:final failure) => failure,
      };

  /// Collapses both branches into one value.
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) =>
      switch (this) {
        Success<T>(:final value) => onSuccess(value),
        FailureResult<T>(:final failure) => onFailure(failure),
      };

  /// Transforms a success, leaving a failure untouched.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
        Success<T>(:final value) => Result<R>.success(transform(value)),
        FailureResult<T>(:final failure) => Result<R>.failure(failure),
      };

  /// Chains another fallible step onto a success.
  Future<Result<R>> flatMap<R>(
    Future<Result<R>> Function(T value) transform,
  ) async =>
      switch (this) {
        Success<T>(:final value) => await transform(value),
        FailureResult<T>(:final failure) => Result<R>.failure(failure),
      };
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Success<T> && other.value == value);

  @override
  int get hashCode => Object.hash(Success<T>, value);
}

final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);

  final Failure failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FailureResult<T> && other.failure == failure);

  @override
  int get hashCode => Object.hash(FailureResult<T>, failure);
}
