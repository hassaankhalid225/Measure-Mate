import 'package:flutter/material.dart';

import '../../core/formatting.dart';
import '../../widgets/calc_scaffold.dart';
import '../../widgets/display.dart';
import '../../widgets/inputs.dart';

enum _Mode { mileage, fuelNeeded, distance }

/// 1 mile per US gallon in km/L, and 1 mile per imperial gallon in km/L.
const _kmplPerMpgUs = 0.4251437074976;
const _kmplPerMpgUk = 0.35400619;

class FuelScreen extends StatefulWidget {
  const FuelScreen({super.key});

  @override
  State<FuelScreen> createState() => _FuelScreenState();
}

class _FuelScreenState extends State<FuelScreen> {
  _Mode _mode = _Mode.mileage;
  final _distance = TextEditingController();
  final _fuel = TextEditingController();
  final _mileage = TextEditingController();
  final _price = TextEditingController();

  @override
  void dispose() {
    _distance.dispose();
    _fuel.dispose();
    _mileage.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Fuel consumption',
      children: [
        SectionCard(
          title: 'What are you working out?',
          children: [
            ModeSelector<_Mode>(
              selected: _mode,
              onChanged: (mode) => setState(() => _mode = mode),
              options: const [
                ModeOption(_Mode.mileage, 'Mileage'),
                ModeOption(_Mode.fuelNeeded, 'Fuel needed'),
                ModeOption(_Mode.distance, 'Distance possible'),
              ],
            ),
            const SizedBox(height: 18),
            if (_mode != _Mode.distance)
              NumberField(
                controller: _distance,
                label: 'Distance travelled',
                suffix: 'km',
                onChanged: (_) => setState(() {}),
              ),
            if (_mode == _Mode.mileage) ...[
              const SizedBox(height: 12),
              NumberField(
                controller: _fuel,
                label: 'Fuel used',
                suffix: 'litres',
                onChanged: (_) => setState(() {}),
              ),
            ],
            if (_mode == _Mode.distance)
              NumberField(
                controller: _fuel,
                label: 'Fuel available',
                suffix: 'litres',
                onChanged: (_) => setState(() {}),
              ),
            if (_mode != _Mode.mileage) ...[
              const SizedBox(height: 12),
              NumberField(
                controller: _mileage,
                label: 'Vehicle mileage',
                suffix: 'km/L',
                onChanged: (_) => setState(() {}),
              ),
            ],
            const SizedBox(height: 12),
            NumberField(
              controller: _price,
              label: 'Fuel price per litre (optional)',
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
        ..._results(),
      ],
    );
  }

  List<Widget> _results() {
    final price = parseNumber(_price.text);

    switch (_mode) {
      case _Mode.mileage:
        final distance = parseNumber(_distance.text);
        final fuel = parseNumber(_fuel.text);
        if (distance == null || fuel == null) {
          return [const EmptyHint('Enter the distance and the fuel used.')];
        }
        if (fuel <= 0) {
          return [const EmptyHint('Fuel used must be greater than zero.')];
        }
        final kmpl = distance / fuel;
        return [
          ResultHero(
            label: 'Mileage',
            value: formatFixed(kmpl, 2),
            unit: 'km/L',
            caption: '${formatFixed(100 / kmpl, 2)} L per 100 km',
          ),
          SectionCard(
            title: 'Same figure, other units',
            children: [
              ResultRow(
                label: 'Litres / 100 km',
                value: formatFixed(100 / kmpl, 2),
              ),
              const Divider(),
              ResultRow(
                label: 'Miles / gallon (US)',
                value: formatFixed(kmpl / _kmplPerMpgUs, 2),
              ),
              const Divider(),
              ResultRow(
                label: 'Miles / gallon (UK)',
                value: formatFixed(kmpl / _kmplPerMpgUk, 2),
              ),
            ],
          ),
          if (price != null) _costCard(fuel * price, kmpl, price, distance),
        ];

      case _Mode.fuelNeeded:
        final distance = parseNumber(_distance.text);
        final kmpl = parseNumber(_mileage.text);
        if (distance == null || kmpl == null) {
          return [const EmptyHint('Enter the distance and your mileage.')];
        }
        if (kmpl <= 0) {
          return [const EmptyHint('Mileage must be greater than zero.')];
        }
        final fuel = distance / kmpl;
        return [
          ResultHero(
            label: 'Fuel needed',
            value: formatFixed(fuel, 2),
            unit: 'litres',
            caption: 'For ${formatNumberGrouped(distance)} km '
                'at ${formatFixed(kmpl, 2)} km/L',
          ),
          if (price != null) _costCard(fuel * price, kmpl, price, distance),
        ];

      case _Mode.distance:
        final fuel = parseNumber(_fuel.text);
        final kmpl = parseNumber(_mileage.text);
        if (fuel == null || kmpl == null) {
          return [
            const EmptyHint('Enter the fuel available and your mileage.'),
          ];
        }
        final distance = fuel * kmpl;
        return [
          ResultHero(
            label: 'You can travel',
            value: formatFixed(distance, 1),
            unit: 'km',
            caption: '${formatFixed(distance / 1.609344, 1)} miles',
          ),
          if (price != null) _costCard(fuel * price, kmpl, price, distance),
        ];
    }
  }

  Widget _costCard(
    double totalCost,
    double kmpl,
    double price,
    double distance,
  ) {
    return SectionCard(
      title: 'Cost',
      children: [
        ResultRow(
          label: 'Total fuel cost',
          value: formatMoney(totalCost),
          emphasise: true,
        ),
        const Divider(),
        ResultRow(
          label: 'Cost per km',
          value: formatMoney(price / kmpl),
        ),
        const Divider(),
        ResultRow(
          label: 'Cost per 100 km',
          value: formatMoney(price / kmpl * 100),
        ),
        if (distance > 0) ...[
          const Divider(),
          ResultRow(
            label: 'Distance covered',
            value: '${formatNumberGrouped(distance)} km',
          ),
        ],
      ],
    );
  }
}
