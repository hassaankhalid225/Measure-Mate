import 'package:flutter/material.dart';

import '../../core/formatting.dart';
import '../../widgets/calc_scaffold.dart';
import '../../widgets/display.dart';
import '../../widgets/inputs.dart';

enum _Mode { add, remove }

class GstScreen extends StatefulWidget {
  const GstScreen({super.key});

  @override
  State<GstScreen> createState() => _GstScreenState();
}

class _GstScreenState extends State<GstScreen> {
  _Mode _mode = _Mode.add;
  final _amount = TextEditingController();
  final _rate = TextEditingController(text: '18');

  static const _slabs = <double>[0.25, 3, 5, 12, 18, 28];

  @override
  void dispose() {
    _amount.dispose();
    _rate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amount = parseNumber(_amount.text);
    final rate = parseNumber(_rate.text);

    return CalcScaffold(
      title: 'GST / Tax',
      children: [
        SectionCard(
          title: 'Calculation',
          children: [
            ModeSelector<_Mode>(
              selected: _mode,
              onChanged: (mode) => setState(() => _mode = mode),
              options: const [
                ModeOption(_Mode.add, 'Add tax (exclusive)'),
                ModeOption(_Mode.remove, 'Remove tax (inclusive)'),
              ],
            ),
            const SizedBox(height: 18),
            NumberField(
              controller: _amount,
              label: _mode == _Mode.add
                  ? 'Amount before tax'
                  : 'Amount including tax',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            NumberField(
              controller: _rate,
              label: 'Tax rate',
              suffix: '%',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final slab in _slabs)
                  ChoiceChip(
                    label: Text('${formatNumber(slab)}%'),
                    selected: rate == slab,
                    showCheckmark: false,
                    onSelected: (_) => setState(() {
                      _rate.text = formatNumber(slab);
                    }),
                  ),
              ],
            ),
          ],
        ),
        if (amount == null || rate == null)
          const EmptyHint('Enter an amount and a tax rate.')
        else if (_mode == _Mode.remove && rate <= -100)
          const EmptyHint('Tax rate is out of range.')
        else
          ..._results(amount, rate),
      ],
    );
  }

  List<Widget> _results(double amount, double rate) {
    final double net;
    final double tax;
    final double total;

    if (_mode == _Mode.add) {
      net = amount;
      tax = amount * rate / 100;
      total = net + tax;
    } else {
      net = amount * 100 / (100 + rate);
      tax = amount - net;
      total = amount;
    }

    return [
      ResultHero(
        label: _mode == _Mode.add ? 'Total payable' : 'Amount before tax',
        value: formatMoney(_mode == _Mode.add ? total : net),
        caption: 'Tax at ${formatNumber(rate)}% = ${formatMoney(tax)}',
      ),
      SectionCard(
        title: 'Breakdown',
        children: [
          ResultRow(label: 'Net (taxable) amount', value: formatMoney(net)),
          const Divider(),
          ResultRow(
            label: 'Tax amount',
            value: formatMoney(tax),
            emphasise: true,
          ),
          const Divider(),
          ResultRow(
            label: 'Gross (total) amount',
            value: formatMoney(total),
            emphasise: true,
          ),
        ],
      ),
      SectionCard(
        title: 'GST split (India)',
        children: [
          ResultRow(
            label: 'CGST (${formatNumber(rate / 2)}%)',
            value: formatMoney(tax / 2),
          ),
          const Divider(),
          ResultRow(
            label: 'SGST / UTGST (${formatNumber(rate / 2)}%)',
            value: formatMoney(tax / 2),
          ),
          const Divider(),
          ResultRow(
            label: 'IGST (${formatNumber(rate)}%)',
            value: formatMoney(tax),
          ),
          const InfoNote(
            'CGST + SGST applies within a state. IGST applies to inter-state '
            'supply — use one or the other, not both.',
          ),
        ],
      ),
    ];
  }
}
