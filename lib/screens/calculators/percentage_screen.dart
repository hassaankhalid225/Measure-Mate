import 'package:flutter/material.dart';

import '../../core/formatting.dart';
import '../../widgets/calc_scaffold.dart';
import '../../widgets/display.dart';
import '../../widgets/inputs.dart';

enum _Mode { percentOf, whatPercent, change, addSubtract }

class PercentageScreen extends StatefulWidget {
  const PercentageScreen({super.key});

  @override
  State<PercentageScreen> createState() => _PercentageScreenState();
}

class _PercentageScreenState extends State<PercentageScreen> {
  _Mode _mode = _Mode.percentOf;
  final _first = TextEditingController();
  final _second = TextEditingController();

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    super.dispose();
  }

  ({String first, String second, String? firstSuffix, String? secondSuffix})
      get _labels {
    switch (_mode) {
      case _Mode.percentOf:
        return (
          first: 'Percentage',
          second: 'Of value',
          firstSuffix: '%',
          secondSuffix: null,
        );
      case _Mode.whatPercent:
        return (
          first: 'This value',
          second: 'Out of',
          firstSuffix: null,
          secondSuffix: null,
        );
      case _Mode.change:
        return (
          first: 'Original value',
          second: 'New value',
          firstSuffix: null,
          secondSuffix: null,
        );
      case _Mode.addSubtract:
        return (
          first: 'Value',
          second: 'Percentage',
          firstSuffix: null,
          secondSuffix: '%',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = _labels;
    final a = parseNumber(_first.text);
    final b = parseNumber(_second.text);

    return CalcScaffold(
      title: 'Percentage',
      children: [
        SectionCard(
          title: 'What do you want to work out?',
          children: [
            ModeSelector<_Mode>(
              selected: _mode,
              onChanged: (mode) => setState(() => _mode = mode),
              options: const [
                ModeOption(_Mode.percentOf, '% of a value'),
                ModeOption(_Mode.whatPercent, 'What % is it'),
                ModeOption(_Mode.change, '% change'),
                ModeOption(_Mode.addSubtract, 'Add / subtract %'),
              ],
            ),
            const SizedBox(height: 18),
            NumberField(
              controller: _first,
              label: labels.first,
              suffix: labels.firstSuffix,
              allowNegative: true,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            NumberField(
              controller: _second,
              label: labels.second,
              suffix: labels.secondSuffix,
              allowNegative: true,
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
        if (a == null || b == null)
          const EmptyHint('Enter both values to see the result.')
        else
          ..._results(a, b),
      ],
    );
  }

  List<Widget> _results(double a, double b) {
    switch (_mode) {
      case _Mode.percentOf:
        final result = b * a / 100;
        return [
          ResultHero(
            label: '${formatNumber(a)}% of ${formatNumberGrouped(b)}',
            value: formatNumberGrouped(result),
          ),
          SectionCard(
            title: 'Also useful',
            children: [
              ResultRow(
                label: 'Value plus that percentage',
                value: formatNumberGrouped(b + result),
              ),
              const Divider(),
              ResultRow(
                label: 'Value minus that percentage',
                value: formatNumberGrouped(b - result),
              ),
            ],
          ),
        ];

      case _Mode.whatPercent:
        if (b == 0) {
          return [const EmptyHint('"Out of" cannot be zero.')];
        }
        final percent = a / b * 100;
        return [
          ResultHero(
            label: '${formatNumberGrouped(a)} out of ${formatNumberGrouped(b)}',
            value: formatNumber(percent),
            unit: '%',
            caption: 'The remaining ${formatNumber(100 - percent)}% '
                'is ${formatNumberGrouped(b - a)}.',
          ),
        ];

      case _Mode.change:
        if (a == 0) {
          return [
            const EmptyHint('Percentage change from zero is undefined.'),
          ];
        }
        final difference = b - a;
        final percent = difference / a.abs() * 100;
        final increased = difference >= 0;
        return [
          ResultHero(
            label: increased ? 'Increase' : 'Decrease',
            value: '${increased ? '+' : ''}${formatNumber(percent)}',
            unit: '%',
            caption: '${formatNumberGrouped(a)} → ${formatNumberGrouped(b)}',
          ),
          SectionCard(
            title: 'Details',
            children: [
              ResultRow(
                label: 'Absolute difference',
                value: formatNumberGrouped(difference.abs()),
              ),
              const Divider(),
              ResultRow(
                label: 'New value as % of original',
                value: '${formatNumber(b / a * 100)}%',
              ),
            ],
          ),
        ];

      case _Mode.addSubtract:
        final amount = a * b / 100;
        return [
          ResultHero(
            label: 'Increased by ${formatNumber(b)}%',
            value: formatNumberGrouped(a + amount),
          ),
          ResultHero(
            label: 'Decreased by ${formatNumber(b)}%',
            value: formatNumberGrouped(a - amount),
          ),
          SectionCard(
            title: 'Details',
            children: [
              ResultRow(
                label: '${formatNumber(b)}% of ${formatNumberGrouped(a)}',
                value: formatNumberGrouped(amount),
              ),
            ],
          ),
        ];
    }
  }
}
