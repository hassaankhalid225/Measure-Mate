import 'package:flutter/material.dart';

import '../../core/date_utils.dart';
import '../../core/formatting.dart';
import '../../widgets/calc_scaffold.dart';
import '../../widgets/display.dart';
import '../../widgets/inputs.dart';

class AgeScreen extends StatefulWidget {
  const AgeScreen({super.key});

  @override
  State<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends State<AgeScreen> {
  DateTime _birthDate = DateTime(today().year - 25, today().month, today().day);
  DateTime _asOf = today();

  @override
  Widget build(BuildContext context) {
    final isFuture = _birthDate.isAfter(_asOf);

    return CalcScaffold(
      title: 'Age',
      children: [
        SectionCard(
          title: 'Dates',
          children: [
            DateField(
              label: 'Date of birth',
              value: _birthDate,
              lastDate: DateTime(2200),
              onChanged: (date) => setState(() => _birthDate = date),
            ),
            const SizedBox(height: 12),
            DateField(
              label: 'Age at date',
              value: _asOf,
              onChanged: (date) => setState(() => _asOf = date),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() => _asOf = today()),
                icon: const Icon(Icons.today_outlined, size: 18),
                label: const Text('Use today'),
              ),
            ),
          ],
        ),
        if (isFuture)
          const EmptyHint('The date of birth is after the target date.')
        else
          ..._results(),
      ],
    );
  }

  List<Widget> _results() {
    final diff = calendarDiff(_birthDate, _asOf);
    final totalDays = daysBetween(_birthDate, _asOf);
    final totalMonths = monthsBetween(_birthDate, _asOf);
    final nextBirthday = nextAnniversary(_birthDate, _asOf);
    final daysToBirthday = daysBetween(_asOf, nextBirthday);
    final turning = nextBirthday.year - _birthDate.year;

    return [
      ResultHero(
        label: 'Age',
        value: '${diff.years} y  ${diff.months} m  ${diff.days} d',
        caption: '${plural(diff.years, 'year')}, '
            '${plural(diff.months, 'month')} and '
            '${plural(diff.days, 'day')}',
      ),
      SectionCard(
        title: 'The same age, counted differently',
        children: [
          ResultRow(
            label: 'In months',
            value: plural(totalMonths, 'month'),
          ),
          const Divider(),
          ResultRow(
            label: 'In weeks',
            value: '${plural(totalDays ~/ 7, 'week')}'
                '${totalDays % 7 == 0 ? '' : ', ${totalDays % 7} d'}',
          ),
          const Divider(),
          ResultRow(label: 'In days', value: plural(totalDays, 'day')),
          const Divider(),
          ResultRow(
            label: 'In hours',
            value: plural(totalDays * 24, 'hour'),
          ),
          const Divider(),
          ResultRow(
            label: 'In minutes',
            value: plural(totalDays * 24 * 60, 'minute'),
          ),
        ],
      ),
      SectionCard(
        title: 'Birthday',
        children: [
          ResultRow(
            label: 'Born on a',
            value: kWeekdayNames[_birthDate.weekday - 1],
          ),
          const Divider(),
          ResultRow(
            label: 'Next birthday',
            value: formatDate(nextBirthday),
          ),
          const Divider(),
          ResultRow(
            label: 'Falls on a',
            value: kWeekdayNames[nextBirthday.weekday - 1],
          ),
          const Divider(),
          ResultRow(
            label: 'Days to go',
            value: plural(daysToBirthday, 'day'),
            emphasise: true,
          ),
          const Divider(),
          ResultRow(label: 'Turning', value: '$turning'),
        ],
      ),
    ];
  }
}
