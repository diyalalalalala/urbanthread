import '../../../../core/errors/failures.dart';

abstract final class OrderFailures {
  const OrderFailures._();

  static bool isPaymentDeclined(Failure failure) {
    if (failure is! ValidationFailure) return false;
    return failure.forField('paymentMethod') != null ||
        failure.message.toLowerCase().contains('declined');
  }

  static bool isCartProblem(Failure failure) =>
      failure is ValidationFailure && failure.forField('items') != null;

  static bool isCouponProblem(Failure failure) =>
      failure is ValidationFailure && failure.forField('coupon') != null;

  static bool isAddressProblem(Failure failure) =>
      failure is ValidationFailure &&
      (failure.forField('shippingAddressId') != null ||
          failure.forField('billingAddressId') != null);

  static List<String> reasons(Failure failure) {
    if (failure is! ValidationFailure || failure.errors.isEmpty) {
      return [failure.message];
    }
    return failure.errors
        .map((error) => error.message)
        .toList(growable: false);
  }
}
