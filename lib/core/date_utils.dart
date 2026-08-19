/// Calendar helpers. All arithmetic is done on UTC date-only values so that
/// daylight-saving shifts can never move a result by a day.
library;

DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime _utc(DateTime date) => DateTime.utc(date.year, date.month, date.day);

DateTime today() => dateOnly(DateTime.now());

/// Whole days from [from] to [to]. Negative when [to] is earlier.
int daysBetween(DateTime from, DateTime to) =>
    _utc(to).difference(_utc(from)).inDays;

/// The gap between two dates expressed the way people say it out loud:
/// "3 years, 2 months and 5 days". Always non-negative.
({int years, int months, int days}) calendarDiff(DateTime from, DateTime to) {
  var start = dateOnly(from);
  var end = dateOnly(to);
  if (end.isBefore(start)) {
    final swap = start;
    start = end;
    end = swap;
  }

  // Take as many whole calendar months as fit, then count the leftover days.
  // Anchoring on addMonths keeps month-end cases sane: 31 Jan -> 1 Mar is
  // "1 month and 1 day", because 31 Jan + 1 month clamps to 28/29 Feb.
  var months = (end.year - start.year) * 12 + (end.month - start.month);
  if (addMonths(start, months).isAfter(end)) months--;
  if (months < 0) months = 0;

  final days = daysBetween(addMonths(start, months), end);

  return (years: months ~/ 12, months: months % 12, days: days);
}

/// Whole calendar months between two dates.
int monthsBetween(DateTime from, DateTime to) {
  final diff = calendarDiff(from, to);
  return diff.years * 12 + diff.months;
}

/// Counts Monday–Friday days in `[from, to)`. Computed in constant time for
/// the whole weeks, so huge ranges stay instant.
int weekdaysBetween(DateTime from, DateTime to) {
  var start = _utc(from);
  var end = _utc(to);
  if (end.isBefore(start)) {
    final swap = start;
    start = end;
    end = swap;
  }

  final totalDays = end.difference(start).inDays;
  var count = (totalDays ~/ 7) * 5;

  final remainder = totalDays % 7;
  for (var i = 0; i < remainder; i++) {
    if (start.add(Duration(days: i)).weekday <= DateTime.friday) count++;
  }
  return count;
}

/// Adds [months] to [date], clamping the day to the end of the target month
/// (31 Jan + 1 month = 28/29 Feb).
DateTime addMonths(DateTime date, int months) {
  final total = date.year * 12 + (date.month - 1) + months;
  final year = (total / 12).floor();
  final month = total - year * 12 + 1;
  final lastDay = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, date.day.clamp(1, lastDay));
}

bool isLeapYear(int year) =>
    (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;

/// The next occurrence of [date]'s day/month strictly after [reference].
DateTime nextAnniversary(DateTime date, DateTime reference) {
  final ref = dateOnly(reference);
  var next = DateTime(ref.year, date.month, date.day);
  if (!next.isAfter(ref)) {
    next = DateTime(ref.year + 1, date.month, date.day);
  }
  return next;
}
