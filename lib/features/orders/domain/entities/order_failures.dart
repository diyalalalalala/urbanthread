import '../../../../core/errors/failures.dart';

/// Reads the *meaning* out of the 422s the order routes return.
///
/// Core's [Failure] hierarchy is sealed, so a feature cannot add a
/// `PaymentDeclinedFailure` variant to it. These predicates recover the same
/// information from the [ValidationFailure] the mapper already produced,
/// which keeps the distinction in the domain without reaching into core.
///
/// The field names matched here are the backend's own: it attaches
/// `errors: [{field, message}]` to every 422, and the field tells you which
/// rule tripped even when the messages get reworded.
abstract final class OrderFailures {
  const OrderFailures._();

  /// The mock gateway refused the payment.
  ///
  /// It declines deterministically — when the integer part of `grandTotal`
  /// ends in 7, or when `simulateFailure` was set — and the decline is thrown
  /// **inside the checkout transaction**. So the entire order rolls back:
  /// no order document, no redemption, stock returned to the shelf. Code
  /// handling this must not go looking for a half-created order or offer to
  /// "retry payment" against one; there is nothing there. The only recovery
  /// is to place the order again, which is why the UI keeps the basket intact
  /// and offers cash on delivery instead.
  static bool isPaymentDeclined(Failure failure) {
    if (failure is! ValidationFailure) return false;
    return failure.forField('paymentMethod') != null ||
        failure.message.toLowerCase().contains('declined');
  }

  /// The cart cannot be checked out — empty, a line out of stock, or a
  /// product withdrawn. `GET /cart/validate` reports all of them at once
  /// under the `items` field.
  static bool isCartProblem(Failure failure) =>
      failure is ValidationFailure && failure.forField('items') != null;

  /// The coupon was rejected: expired, over its usage limit, or below the
  /// minimum spend.
  static bool isCouponProblem(Failure failure) =>
      failure is ValidationFailure && failure.forField('coupon') != null;

  /// The chosen address is not (or no longer) in the user's address book.
  static bool isAddressProblem(Failure failure) =>
      failure is ValidationFailure &&
      (failure.forField('shippingAddressId') != null ||
          failure.forField('billingAddressId') != null);

  /// The account's email address has not been confirmed, so the backend's
  /// `requireVerifiedEmail` closed checkout. Worth naming because the right
  /// response is an explanation and a "resend link" button, not the generic
  /// permission message a bare 403 would show.
  static bool isEmailUnverified(Failure failure) => failure is ForbiddenFailure;

  /// Every blocking message the server listed, in order. A 422 from
  /// `/cart/validate` carries one entry per problem, and showing only the
  /// first would send the customer round the loop once per issue.
  static List<String> reasons(Failure failure) {
    if (failure is! ValidationFailure || failure.errors.isEmpty) {
      return [failure.message];
    }
    return failure.errors
        .map((error) => error.message)
        .toList(growable: false);
  }
}
