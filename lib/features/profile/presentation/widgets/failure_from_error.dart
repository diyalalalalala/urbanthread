import '../../../../core/errors/failures.dart';

/// Narrows the `Object` an [AsyncValue] error carries back to a [Failure].
///
/// The notifiers in this feature throw the domain's [Failure] so `AsyncValue`
/// can carry it, but its `error` field is typed `Object` — every screen would
/// otherwise repeat the same cast before it could hand the value to
/// `FailureView`. Core has no equivalent helper; if one is added there, this
/// should be deleted in favour of it.
Failure failureFrom(Object? error) =>
    error is Failure ? error : const UnexpectedFailure();
