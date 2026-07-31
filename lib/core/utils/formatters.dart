import 'package:intl/intl.dart';

abstract final class Formatters {
  const Formatters._();

  static final _integerPrice = NumberFormat('#,##0', 'en_US');
  static final _decimalPrice = NumberFormat('#,##0.00', 'en_US');
  static final _dayMonthYear = DateFormat('d MMM yyyy');
  static final _dayMonthYearTime = DateFormat('d MMM yyyy, h:mm a');
  static final _compact = NumberFormat.compact(locale: 'en_US');

  static String price(num? amount, {String symbol = 'Rs'}) {
    final value = amount ?? 0;
    final hasFraction = (value % 1).abs() > 0.001;
    final formatted =
        hasFraction ? _decimalPrice.format(value) : _integerPrice.format(value);
    return '$symbol $formatted';
  }

  static String? discountBadge(num? discountPercentage) {
    final value = discountPercentage ?? 0;
    if (value <= 0) return null;
    return '${_integerPrice.format(value)}% off';
  }

  static String date(Object? value) {
    final parsed = _parseDate(value);
    return parsed == null ? '—' : _dayMonthYear.format(parsed.toLocal());
  }

  static String dateTime(Object? value) {
    final parsed = _parseDate(value);
    return parsed == null ? '—' : _dayMonthYearTime.format(parsed.toLocal());
  }

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

  static String compact(num? value) => _compact.format(value ?? 0);

  static String items(int count) => '$count ${count == 1 ? 'item' : 'items'}';

  static String _plural(int count, String unit) =>
      '$count ${count == 1 ? unit : '${unit}s'} ago';

  static DateTime? _parseDate(Object? value) => switch (value) {
        DateTime date => date,
        String text when text.isNotEmpty => DateTime.tryParse(text),
        _ => null,
      };
}
