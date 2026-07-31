import '../../../../core/errors/failures.dart';

Failure failureFrom(Object? error) =>
    error is Failure ? error : const UnexpectedFailure();
