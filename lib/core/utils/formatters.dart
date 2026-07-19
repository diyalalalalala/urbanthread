import 'package:intl/intl.dart';

/// Presentation-side formatting for money, dates and counts.
///
/// The API reports every price in NPR (`pricing.currency`, `summary.currency`)
/// and never localises, so formatting is the client's job.
abstract final class Formatters {
  const Formatters._();

  static final _integerPrice = NumberFormat('#,##0', 'en_US');
  static final _decimalPrice = NumberFormat('#,##0.00', 'en_US');
  static final _dayMonthYear = DateFormat('d MMM yyyy');
  static final _dayMonthYearTime = DateFormat('d MMM yyyy, h:mm a');
  static final _compact = NumberFormat.compact(locale: 'en_US');

  /// `Rs 2,499` — or `Rs 2,499.50` when the amount has real paise.
  ///
  /// Trailing `.00` is dropped because catalogue prices are whole rupees in
  /// practice, and a grid of `Rs 2,499.00` reads as noise. Computed totals
  /// (tax at 13%) genuinely can carry decimals, so those keep both places.
  static String price(num? amount, {String symbol = 'Rs'}) {
    final value = amount ?? 0;
    final hasFraction = (value % 1).abs() > 0.001;
    final formatted =
        hasFraction ? _decimalPrice.format(value) : _integerPrice.format(value);
    return '$symbol $formatted';
  }

  /// `20% off`, or null when there is no discount to advertise.
  static String? discountBadge(num? discountPercentage) {
    final value = discountPercentage ?? 0;
    if (value <= 0) return null;
    return '${_integerPrice.format(value)}% off';
  }

  /// `18 Jul 2026`. Accepts the API's ISO-8601 strings directly.
  static String date(Object? value) {
    final parsed = _parseDate(value);
    return parsed == null ? '—' : _dayMonthYear.format(parsed.toLocal());
  }

  /// `18 Jul 2026, 4:32 PM`.
  static String dateTime(Object? value) {
    final parsed = _parseDate(value);
    return parsed == null ? '—' : _dayMonthYearTime.format(parsed.toLocal());
  }

  /// `2 hours ago`, for notifications and review timestamps.
  static String relative(Object? value) {
    final parsed = _parseDate(value)?.toLocal();
    if (parsed == null) return '—';

    final diff = DateTime.now().difference(parsed);
    if (diff.isNegative) return 'Just now';
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return _plural(diff.inMinutes, 'minute');
    if (diff.inHours < 24) return _plural(diff.inHours, 'hour');
    if (diff.inDays < 7) return _plural(diff.inDays, 'day');
    if (diff.inDays < 30) return _plural(diff.inDays ~/ 7, 'week');
    if (diff.inDays < 365) return _plural(diff.inDays ~/ 30, 'month');
    return _plural(diff.inDays ~/ 365, 'year');
  }

  /// `1.2K` — for review counts and similar.
  static String compact(num? value) => _compact.format(value ?? 0);

  /// `1 item` / `3 items`.
  static String items(int count) => '$count ${count == 1 ? 'item' : 'items'}';

  static String _plural(int count, String unit) =>
      '$count ${count == 1 ? unit : '${unit}s'} ago';

  static DateTime? _parseDate(Object? value) => switch (value) {
        DateTime date => date,
        String text when text.isNotEmpty => DateTime.tryParse(text),
        _ => null,
      };
}
