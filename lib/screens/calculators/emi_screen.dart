import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/formatting.dart';
import '../../widgets/calc_scaffold.dart';
import '../../widgets/display.dart';
import '../../widgets/inputs.dart';

/// Loan EMI (equated monthly instalment) calculator.
class EmiScreen extends StatefulWidget {
  const EmiScreen({super.key});

  @override
  State<EmiScreen> createState() => _EmiScreenState();
}

class _EmiScreenState extends State<EmiScreen> {
  final _amount = TextEditingController();
  final _rate = TextEditingController();
  final _tenure = TextEditingController();
  bool _tenureInYears = true;

  @override
  void dispose() {
    _amount.dispose();
    _rate.dispose();
    _tenure.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final principal = parseNumber(_amount.text);
    final annualRate = parseNumber(_rate.text);
    final tenure = parseNumber(_tenure.text);

    return CalcScaffold(
      title: 'Loan EMI',
      children: [
        SectionCard(
          title: 'Loan details',
          children: [
            NumberField(
              controller: _amount,
              label: 'Loan amount',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            NumberField(
              controller: _rate,
              label: 'Interest rate (per year)',
              suffix: '%',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            NumberField(
              controller: _tenure,
              label: 'Loan tenure',
              suffix: _tenureInYears ? 'years' : 'months',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            ModeSelector<bool>(
              selected: _tenureInYears,
              onChanged: (years) => setState(() => _tenureInYears = years),
              options: const [
                ModeOption(true, 'Years'),
                ModeOption(false, 'Months'),
              ],
            ),
          ],
        ),
        if (principal == null || annualRate == null || tenure == null)
          const EmptyHint('Enter the amount, rate and tenure.')
        else
          ..._results(principal, annualRate, tenure),
      ],
    );
  }

  List<Widget> _results(double principal, double annualRate, double tenure) {
    final months = (_tenureInYears ? tenure * 12 : tenure).round();
    if (months <= 0) {
      return [const EmptyHint('Tenure must be at least one month.')];
    }
    if (principal <= 0) {
      return [const EmptyHint('Loan amount must be greater than zero.')];
    }

    final monthlyRate = annualRate / 12 / 100;

    // A zero-interest loan is just the principal split evenly, and the
    // standard formula divides by zero there.
    final double emi;
    if (monthlyRate == 0) {
      emi = principal / months;
    } else {
      final growth = math.pow(1 + monthlyRate, months).toDouble();
      emi = principal * monthlyRate * growth / (growth - 1);
    }

    final totalPayable = emi * months;
    final totalInterest = totalPayable - principal;
    final interestShare = totalInterest / principal * 100;

    final years = months ~/ 12;
    final leftoverMonths = months % 12;
    final tenureText = [
      if (years > 0) plural(years, 'year'),
      if (leftoverMonths > 0) plural(leftoverMonths, 'month'),
    ].join(' ');

    return [
      ResultHero(
        label: 'Monthly EMI',
        value: formatMoney(emi),
        caption: '$tenureText · ${plural(months, 'instalment')}',
      ),
      SectionCard(
        title: 'Breakdown',
        children: [
          ResultRow(label: 'Principal', value: formatMoney(principal)),
          const Divider(),
          ResultRow(
            label: 'Total interest',
            value: formatMoney(totalInterest),
            emphasise: true,
          ),
          const Divider(),
          ResultRow(
            label: 'Total payable',
            value: formatMoney(totalPayable),
            emphasise: true,
          ),
          const Divider(),
          ResultRow(
            label: 'Interest as % of loan',
            value: '${formatFixed(interestShare, 1)}%',
          ),
          const InfoNote(
            'Assumes a fixed rate and equal monthly instalments. Banks may add '
            'processing fees, insurance or taxes that are not included here.',
          ),
        ],
      ),
    ];
  }
}
