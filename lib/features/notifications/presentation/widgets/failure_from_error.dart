import '../../../../core/errors/failures.dart';

/// Narrows the `Object` an [AsyncValue] error carries back to a [Failure].
///
/// Duplicated from the profile feature on purpose: the two features must not
/// import each other's presentation layers, and core has no home for it. Fold
/// both into core if one is ever added there.
Failure failureFrom(Object? error) =>
    error is Failure ? error : const UnexpectedFailure();
