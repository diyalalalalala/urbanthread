import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import 'cart_summary.dart';

class CartBlocker extends Equatable {
  const CartBlocker({required this.message, this.field = ''});

  final String field;

  final String message;

  @override
  List<Object?> get props => [field, message];
}

class CartValidation extends Equatable {
  const CartValidation({
    required this.isValid,
    this.blockers = const [],
    this.summary,
  });

  const CartValidation.valid(CartSummary summary)
      : this(isValid: true, summary: summary);

  CartValidation.fromFailure(ValidationFailure failure)
      : isValid = false,
        summary = null,
        blockers = failure.errors.isEmpty
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

  final CartSummary? summary;

  @override
  List<Object?> get props => [isValid, blockers, summary];
}
