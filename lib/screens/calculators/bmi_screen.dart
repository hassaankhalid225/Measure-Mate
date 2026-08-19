import 'package:flutter/material.dart';

import '../../core/formatting.dart';
import '../../widgets/calc_scaffold.dart';
import '../../widgets/display.dart';
import '../../widgets/inputs.dart';

enum _Units { metric, imperial }

class _BmiBand {
  const _BmiBand(this.name, this.from, this.to);
  final String name;
  final double from;
  final double to;
}

const _bands = <_BmiBand>[
  _BmiBand('Underweight', 0, 18.5),
  _BmiBand('Healthy weight', 18.5, 25),
  _BmiBand('Overweight', 25, 30),
  _BmiBand('Obese', 30, double.infinity),
];

_BmiBand _bandFor(double bmi) =>
    _bands.firstWhere((band) => bmi < band.to, orElse: () => _bands.last);

class BmiScreen extends StatefulWidget {
  const BmiScreen({super.key});

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> {
  _Units _units = _Units.metric;
  final _heightCm = TextEditingController();
  final _weightKg = TextEditingController();
  final _heightFt = TextEditingController();
  final _heightIn = TextEditingController();
  final _weightLb = TextEditingController();

  @override
  void dispose() {
    _heightCm.dispose();
    _weightKg.dispose();
    _heightFt.dispose();
    _heightIn.dispose();
    _weightLb.dispose();
    super.dispose();
  }

  /// Height in metres and weight in kilograms, or null when incomplete.
  ({double heightM, double weightKg})? get _measurements {
    if (_units == _Units.metric) {
      final cm = parseNumber(_heightCm.text);
      final kg = parseNumber(_weightKg.text);
      if (cm == null || kg == null || cm <= 0 || kg <= 0) return null;
      return (heightM: cm / 100, weightKg: kg);
    }

    final feet = parseNumber(_heightFt.text) ?? 0;
    final inches = parseNumber(_heightIn.text) ?? 0;
    final pounds = parseNumber(_weightLb.text);
    final totalInches = feet * 12 + inches;
    if (pounds == null || totalInches <= 0 || pounds <= 0) return null;
    return (heightM: totalInches * 0.0254, weightKg: pounds * 0.45359237);
  }

  @override
  Widget build(BuildContext context) {
    final measurements = _measurements;

    return CalcScaffold(
      title: 'BMI',
      children: [
        SectionCard(
          title: 'Your measurements',
          children: [
            ModeSelector<_Units>(
              selected: _units,
              onChanged: (units) => setState(() => _units = units),
              options: const [
                ModeOption(_Units.metric, 'Metric (cm / kg)'),
                ModeOption(_Units.imperial, 'Imperial (ft / lb)'),
              ],
            ),
            const SizedBox(height: 16),
            if (_units == _Units.metric) ...[
              NumberField(
                controller: _heightCm,
                label: 'Height',
                suffix: 'cm',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              NumberField(
                controller: _weightKg,
                label: 'Weight',
                suffix: 'kg',
                onChanged: (_) => setState(() {}),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: NumberField(
                      controller: _heightFt,
                      label: 'Height',
                      suffix: 'ft',
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NumberField(
                      controller: _heightIn,
                      label: 'Inches',
                      suffix: 'in',
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              NumberField(
                controller: _weightLb,
                label: 'Weight',
                suffix: 'lb',
                onChanged: (_) => setState(() {}),
              ),
            ],
          ],
        ),
        if (measurements == null)
          const EmptyHint('Enter your height and weight.')
        else
          ..._results(measurements.heightM, measurements.weightKg),
      ],
    );
  }

  List<Widget> _results(double heightM, double weightKg) {
    final bmi = weightKg / (heightM * heightM);
    final band = _bandFor(bmi);
    final lowerKg = 18.5 * heightM * heightM;
    final upperKg = 24.9 * heightM * heightM;

    final imperial = _units == _Units.imperial;
    String weight(double kg) => imperial
        ? '${formatFixed(kg / 0.45359237, 1)} lb'
        : '${formatFixed(kg, 1)} kg';

    final String advice;
    if (weightKg < lowerKg) {
      advice = 'Gain about ${weight(lowerKg - weightKg)} to reach the '
          'healthy range.';
    } else if (weightKg > upperKg) {
      advice = 'Lose about ${weight(weightKg - upperKg)} to reach the '
          'healthy range.';
    } else {
      advice = 'Your weight is already in the healthy range.';
    }

    return [
      ResultHero(
        label: 'Body mass index',
        value: formatFixed(bmi, 1),
        caption: band.name,
      ),
      SectionCard(
        title: 'Details',
        children: [
          ResultRow(label: 'Category', value: band.name, emphasise: true),
          const Divider(),
          ResultRow(
            label: 'Healthy weight for your height',
            value: '${weight(lowerKg)} – ${weight(upperKg)}',
          ),
          const Divider(),
          ResultRow(
            label: 'BMI needed for healthy range',
            value: '18.5 – 24.9',
          ),
          InfoNote(advice),
        ],
      ),
      SectionCard(
        title: 'All categories',
        children: [
          for (var i = 0; i < _bands.length; i++) ...[
            if (i > 0) const Divider(),
            ResultRow(
              label: _bands[i].name,
              value: _bands[i].to.isFinite
                  ? '${formatFixed(_bands[i].from, 1)} – '
                      '${formatFixed(_bands[i].to, 1)}'
                  : '${formatFixed(_bands[i].from, 1)} and above',
              emphasise: _bands[i].name == band.name,
            ),
          ],
          const InfoNote(
            'BMI is a rough screening tool. It does not account for muscle '
            'mass, body composition, age or ethnicity — ask a doctor before '
            'acting on it.',
          ),
        ],
      ),
    ];
  }
}
