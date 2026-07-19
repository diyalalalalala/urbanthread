/// Client-side form validation.
///
/// These deliberately mirror the backend's express-validator rules rather
/// than inventing stricter ones. A field the client accepts but the server
/// rejects produces a confusing round trip; a field the client rejects but
/// the server would have accepted silently blocks a legitimate user. Where
/// the two must agree, the backend rule is quoted in a comment.
///
/// This is a first line of defence only — the server validates independently,
/// and its 422 field errors are surfaced through `ValidationFailure`.
abstract final class Validators {
  const Validators._();

  static final _emailPattern = RegExp(
    r'^[\w.!#$%&*+/=?^`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
    r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$',
  );

  /// Backend: `/^[+]?[\d\s().-]{7,20}$/`.
  static final _phonePattern = RegExp(r'^[+]?[\d\s().-]{7,20}$');

  static String? required(String? value, {String field = 'This field'}) =>
      (value?.trim().isEmpty ?? true) ? '$field is required' : null;

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Email is required';
    if (!_emailPattern.hasMatch(trimmed)) return 'Enter a valid email address';
    return null;
  }

  /// Backend rule: at least 8 characters, with an uppercase letter, a
  /// lowercase letter and a digit. Each condition is reported separately —
  /// a single "password is invalid" leaves the user guessing which rule
  /// they missed.
  static String? password(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Password is required';
    if (password.length < 8) return 'Use at least 8 characters';
    if (!password.contains(RegExp('[A-Z]'))) {
      return 'Include an uppercase letter';
    }
    if (!password.contains(RegExp('[a-z]'))) {
      return 'Include a lowercase letter';
    }
    if (!password.contains(RegExp('[0-9]'))) return 'Include a number';
    return null;
  }

  /// For the login form only.
  ///
  /// Existing accounts may predate the current password policy, so applying
  /// [password] here would lock them out of their own account before the
  /// request is even sent.
  static String? loginPassword(String? value) =>
      (value?.isEmpty ?? true) ? 'Password is required' : null;

  static String? confirmPassword(String? value, String original) {
    if (value?.isEmpty ?? true) return 'Confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  /// Backend: 2..80 characters.
  static String? name(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Name is required';
    if (trimmed.length < 2) return 'Name is too short';
    if (trimmed.length > 80) return 'Name must be 80 characters or fewer';
    return null;
  }

  /// Optional on registration and on the profile form.
  static String? phone(String? value, {bool isRequired = false}) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return isRequired ? 'Phone number is required' : null;
    if (!_phonePattern.hasMatch(trimmed)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? maxLength(String? value, int max, {String field = 'This'}) {
    if ((value?.length ?? 0) > max) {
      return '$field must be $max characters or fewer';
    }
    return null;
  }

  /// Backend: 10..2000 characters.
  static String? reviewComment(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Write a few words about the product';
    if (trimmed.length < 10) return 'Please write at least 10 characters';
    if (trimmed.length > 2000) return 'Keep it under 2000 characters';
    return null;
  }

  /// Backend: 3..24 characters.
  static String? couponCode(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Enter a coupon code';
    if (trimmed.length < 3 || trimmed.length > 24) {
      return 'That does not look like a valid code';
    }
    return null;
  }

  /// Composes validators, returning the first message that applies.
  static String? Function(String?) all(
    List<String? Function(String?)> validators,
  ) =>
      (value) {
        for (final validate in validators) {
          final message = validate(value);
          if (message != null) return message;
        }
        return null;
      };
}
