import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import 'cart_summary.dart';

/// One reason the cart cannot be checked out.
class CartBlocker extends Equatable {
  const CartBlocker({required this.message, this.field = ''});

  /// The offending line or aspect — `items[2].quantity`, `coupon`, `items`.
  final String field;

  /// Customer-facing text from the backend.
  final String message;

  @override
  List<Object?> get props => [field, message];
}

/// The outcome of `GET /cart/validate`.
///
/// A failed validation is *not* modelled as a [Failure]. The endpoint answers
/// 422 and lists **every** blocker at once — deliberately, so the customer
/// fixes their cart in one pass — and that list is the useful result, not an
/// error to bubble up. So the repository converts the 422 into an
/// unsuccessful-but-valid value and reserves failures for transport problems.
class CartValidation extends Equatable {
  const CartValidation({
    required this.isValid,
    this.blockers = const [],
    this.summary,
  });

  const CartValidation.valid(CartSummary summary)
      : this(isValid: true, summary: summary);

  /// Builds the invalid case from the 422's field errors.
  CartValidation.fromFailure(ValidationFailure failure)
      : isValid = false,
        summary = null,
        blockers = failure.errors.isEmpty
            // A 422 with no `errors` array still has a message worth showing —
            // an empty cart is rejected that way.
            ? [CartBlocker(message: failure.message)]
            : failure.errors
                .map(
                  (error) => CartBlocker(
                    field: error.field,
                    message: error.message,
                  ),
                )
                .toList(growable: false);

  final bool isValid;
  final List<CartBlocker> blockers;

  /// Present only on success — the totals the order will be placed against.
  final CartSummary? summary;

  @override
  List<Object?> get props => [isValid, blockers, summary];
}
