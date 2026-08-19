import 'package:flutter/material.dart';

import '../../core/date_utils.dart';
import '../../core/formatting.dart';
import '../../widgets/calc_scaffold.dart';
import '../../widgets/display.dart';
import '../../widgets/inputs.dart';

enum _Mode { between, shift }

class DateDifferenceScreen extends StatefulWidget {
  const DateDifferenceScreen({super.key});

  @override
  State<DateDifferenceScreen> createState() => _DateDifferenceScreenState();
}

class _DateDifferenceScreenState extends State<DateDifferenceScreen> {
  _Mode _mode = _Mode.between;

  DateTime _start = today();
  // Built via the constructor rather than Duration so a daylight-saving
  // change cannot shift the default by a day.
  DateTime _end = DateTime(today().year, today().month, today().day + 30);
  DateTime _base = today();

  bool _adding = true;
  final _years = TextEditingController();
  final _months = TextEditingController();
  final _weeks = TextEditingController();
  final _days = TextEditingController();

  @override
  void dispose() {
    _years.dispose();
    _months.dispose();
    _weeks.dispose();
    _days.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Date difference',
      children: [
        SectionCard(
          title: 'Mode',
          children: [
            ModeSelector<_Mode>(
              selected: _mode,
              onChanged: (mode) => setState(() => _mode = mode),
              options: const [
                ModeOption(_Mode.between, 'Between two dates'),
                ModeOption(_Mode.shift, 'Add / subtract from a date'),
              ],
            ),
          ],
        ),
        if (_mode == _Mode.between) ...[
          SectionCard(
            title: 'Dates',
            children: [
              DateField(
                label: 'Start date',
                value: _start,
                onChanged: (date) => setState(() => _start = date),
              ),
              const SizedBox(height: 12),
              DateField(
                label: 'End date',
                value: _end,
                onChanged: (date) => setState(() => _end = date),
              ),
            ],
          ),
          ..._betweenResults(),
        ] else ...[
          SectionCard(
            title: 'Starting point',
            children: [
              DateField(
                label: 'Date',
                value: _base,
                onChanged: (date) => setState(() => _base = date),
              ),
              const SizedBox(height: 14),
              ModeSelector<bool>(
                selected: _adding,
                onChanged: (adding) => setState(() => _adding = adding),
                options: const [
                  ModeOption(true, 'Add'),
                  ModeOption(false, 'Subtract'),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: NumberField(
                      controller: _years,
                      label: 'Years',
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NumberField(
                      controller: _months,
                      label: 'Months',
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: NumberField(
                      controller: _weeks,
                      label: 'Weeks',
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NumberField(
                      controller: _days,
                      label: 'Days',
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
            ],
          ),
          ..._shiftResults(),
        ],
      ],
    );
  }

  List<Widget> _betweenResults() {
    final diff = calendarDiff(_start, _end);
    final totalDays = daysBetween(_start, _end).abs();
    final weekdays = weekdaysBetween(_start, _end);
    final weekendDays = totalDays - weekdays;
    final backwards = _end.isBefore(_start);

    return [
      ResultHero(
        label: backwards ? 'Difference (end is earlier)' : 'Difference',
        value: plural(totalDays, 'day'),
        caption: '${plural(diff.years, 'year')}, '
            '${plural(diff.months, 'month')} and '
            '${plural(diff.days, 'day')}',
      ),
      SectionCard(
        title: 'Counted differently',
        children: [
          ResultRow(
            label: 'Months and days',
            value: '${plural(monthsBetween(_start, _end), 'month')}, '
                '${plural(diff.days, 'day')}',
          ),
          const Divider(),
          ResultRow(
            label: 'Weeks and days',
            value: '${plural(totalDays ~/ 7, 'week')}'
                '${totalDays % 7 == 0 ? '' : ', ${totalDays % 7} d'}',
          ),
          const Divider(),
          ResultRow(label: 'Hours', value: plural(totalDays * 24, 'hour')),
          const Divider(),
          ResultRow(
            label: 'Minutes',
            value: plural(totalDays * 24 * 60, 'minute'),
          ),
        ],
      ),
      SectionCard(
        title: 'Working days',
        children: [
          ResultRow(
            label: 'Weekdays (Mon–Fri)',
            value: plural(weekdays, 'day'),
            emphasise: true,
          ),
          const Divider(),
          ResultRow(
            label: 'Weekend days',
            value: plural(weekendDays, 'day'),
          ),
          const Divider(),
          ResultRow(
            label: 'Start date falls on',
            value: kWeekdayNames[_start.weekday - 1],
          ),
          const Divider(),
          ResultRow(
            label: 'End date falls on',
            value: kWeekdayNames[_end.weekday - 1],
          ),
          const InfoNote(
            'The count runs from the start date up to, but not including, '
            'the end date. Public holidays are not considered.',
          ),
        ],
      ),
    ];
  }

  List<Widget> _shiftResults() {
    final years = (parseNumber(_years.text) ?? 0).round();
    final months = (parseNumber(_months.text) ?? 0).round();
    final weeks = (parseNumber(_weeks.text) ?? 0).round();
    final days = (parseNumber(_days.text) ?? 0).round();

    if (years == 0 && months == 0 && weeks == 0 && days == 0) {
      return [const EmptyHint('Enter how much time to add or subtract.')];
    }

    final sign = _adding ? 1 : -1;
    final shifted = addMonths(_base, sign * (years * 12 + months));
    // Building a DateTime with an out-of-range day normalises safely and
    // avoids daylight-saving drift.
    final result = DateTime(
      shifted.year,
      shifted.month,
      shifted.day + sign * (weeks * 7 + days),
    );

    return [
      ResultHero(
        label: _adding ? 'Date after adding' : 'Date after subtracting',
        value: formatDate(result),
        caption: formatDateLong(result),
      ),
      SectionCard(
        title: 'Details',
        children: [
          ResultRow(label: 'Starting date', value: formatDate(_base)),
          const Divider(),
          ResultRow(
            label: 'Shift applied',
            value: [
              if (years != 0) plural(years, 'year'),
              if (months != 0) plural(months, 'month'),
              if (weeks != 0) plural(weeks, 'week'),
              if (days != 0) plural(days, 'day'),
            ].join(', '),
          ),
          const Divider(),
          ResultRow(
            label: 'Days from start',
            value: plural(daysBetween(_base, result).abs(), 'day'),
          ),
          const Divider(),
          ResultRow(
            label: 'Day of week',
            value: kWeekdayNames[result.weekday - 1],
          ),
        ],
      ),
    ];
  }
}
