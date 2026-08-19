import 'package:flutter/material.dart';

import '../../core/formatting.dart';
import '../../widgets/calc_scaffold.dart';
import '../../widgets/display.dart';
import '../../widgets/inputs.dart';

/// Splits a restaurant bill and works out the tip.
class TipScreen extends StatefulWidget {
  const TipScreen({super.key});

  @override
  State<TipScreen> createState() => _TipScreenState();
}

class _TipScreenState extends State<TipScreen> {
  final _bill = TextEditingController();
  final _tipRate = TextEditingController(text: '10');
  int _people = 1;

  static const _quickTips = <double>[5, 10, 12.5, 15, 18, 20];

  @override
  void dispose() {
    _bill.dispose();
    _tipRate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bill = parseNumber(_bill.text);
    final rate = parseNumber(_tipRate.text);

    return CalcScaffold(
      title: 'Tip & split',
      children: [
        SectionCard(
          title: 'The bill',
          children: [
            NumberField(
              controller: _bill,
              label: 'Bill amount',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            NumberField(
              controller: _tipRate,
              label: 'Tip',
              suffix: '%',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tip in _quickTips)
                  ChoiceChip(
                    label: Text('${formatNumber(tip)}%'),
                    selected: rate == tip,
                    onSelected: (_) => setState(() {
                      _tipRate.text = formatNumber(tip);
                    }),
                  ),
              ],
            ),
          ],
        ),
        SectionCard(
          title: 'Split between',
          children: [
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: _people > 1
                      ? () => setState(() => _people--)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Expanded(
                  child: Text(
                    plural(_people, 'person', 'people'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: _people < 50
                      ? () => setState(() => _people++)
                      : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
        if (bill == null || rate == null)
          const EmptyHint('Enter the bill amount and a tip percentage.')
        else
          ..._results(bill, rate),
      ],
    );
  }

  List<Widget> _results(double bill, double rate) {
    final tip = bill * rate / 100;
    final total = bill + tip;

    return [
      ResultHero(
        label: _people > 1 ? 'Each person pays' : 'Total to pay',
        value: formatMoney(total / _people),
        caption: _people > 1
            ? 'Total ${formatMoney(total)} split $_people ways'
            : 'Bill ${formatMoney(bill)} + ${formatNumber(rate)}% tip',
      ),
      SectionCard(
        title: 'Breakdown',
        children: [
          ResultRow(label: 'Bill', value: formatMoney(bill)),
          const Divider(),
          ResultRow(
            label: 'Tip (${formatNumber(rate)}%)',
            value: formatMoney(tip),
            emphasise: true,
          ),
          const Divider(),
          ResultRow(
            label: 'Total',
            value: formatMoney(total),
            emphasise: true,
          ),
          if (_people > 1) ...[
            const Divider(),
            ResultRow(
              label: 'Tip per person',
              value: formatMoney(tip / _people),
            ),
            const Divider(),
            ResultRow(
              label: 'Bill per person',
              value: formatMoney(bill / _people),
            ),
          ],
        ],
      ),
    ];
  }
}
