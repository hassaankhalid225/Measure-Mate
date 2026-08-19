/// Number parsing and display helpers shared by every screen.
library;

/// Parses user input such as `1,250.75` or `-3.5` into a double.
/// Returns null when the text is empty or not a number.
double? parseNumber(String? text) {
  if (text == null) return null;
  final cleaned = text.replaceAll(',', '').replaceAll(' ', '').trim();
  if (cleaned.isEmpty || cleaned == '-' || cleaned == '.' || cleaned == '-.') {
    return null;
  }
  return double.tryParse(cleaned);
}

/// Formats a double for display: trims trailing zeros, falls back to
/// scientific notation for very large / very small magnitudes.
String formatNumber(double value, {int significantDigits = 10}) {
  if (value.isNaN) return '—';
  if (value.isInfinite) return value.isNegative ? '-∞' : '∞';
  if (value == 0) return '0';

  final magnitude = value.abs();
  if (magnitude >= 1e15 || magnitude < 1e-9) {
    final parts = value.toStringAsExponential(6).split('e');
    return '${_trimZeros(parts[0])}e${parts[1]}';
  }

  var text = value.toStringAsPrecision(significantDigits);
  if (text.contains('e') || text.contains('E')) {
    text = value.toStringAsFixed(12);
  }
  return _trimZeros(text);
}

/// Same as [formatNumber] but with thousands separators, for readability.
String formatNumberGrouped(double value, {int significantDigits = 10}) {
  return groupDigits(
    formatNumber(value, significantDigits: significantDigits),
  );
}

/// Formats a money amount with two decimals and thousands separators.
String formatMoney(double value) {
  if (value.isNaN || value.isInfinite) return '—';
  return groupDigits(value.toStringAsFixed(2));
}

/// Rounds to [decimals] places and drops trailing zeros (`12.50` -> `12.5`).
String formatFixed(double value, int decimals) {
  if (value.isNaN) return '—';
  if (value.isInfinite) return value.isNegative ? '-∞' : '∞';
  return _trimZeros(value.toStringAsFixed(decimals));
}

/// Inserts `,` every three digits in the integer part of a numeric string.
String groupDigits(String number) {
  if (number.contains('e') || number.contains('E')) return number;

  final isNegative = number.startsWith('-');
  final body = isNegative ? number.substring(1) : number;

  final dotIndex = body.indexOf('.');
  final integerPart = dotIndex == -1 ? body : body.substring(0, dotIndex);
  final decimalPart = dotIndex == -1 ? '' : body.substring(dotIndex);

  final buffer = StringBuffer();
  for (var i = 0; i < integerPart.length; i++) {
    if (i > 0 && (integerPart.length - i) % 3 == 0) buffer.write(',');
    buffer.write(integerPart[i]);
  }

  return '${isNegative ? '-' : ''}$buffer$decimalPart';
}

/// `1 day` / `3 days`
String plural(num count, String singular, [String? pluralForm]) {
  final word = count == 1 ? singular : (pluralForm ?? '${singular}s');
  return '${groupDigits(count.toString())} $word';
}

const List<String> kMonthNames = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const List<String> kWeekdayNames = <String>[
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

/// `9 Aug 2026`
String formatDate(DateTime date) {
  final month = kMonthNames[date.month - 1].substring(0, 3);
  return '${date.day} $month ${date.year}';
}

/// `Sunday, 9 August 2026`
String formatDateLong(DateTime date) {
  final weekday = kWeekdayNames[date.weekday - 1];
  return '$weekday, ${date.day} ${kMonthNames[date.month - 1]} ${date.year}';
}

String _trimZeros(String text) {
  if (!text.contains('.')) return text;
  var result = text.replaceFirst(RegExp(r'0+$'), '');
  if (result.endsWith('.')) result = result.substring(0, result.length - 1);
  if (result == '-0') return '0';
  return result;
}
