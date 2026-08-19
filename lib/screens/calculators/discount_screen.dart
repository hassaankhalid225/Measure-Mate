import 'package:flutter/material.dart';

import '../../core/formatting.dart';
import '../../widgets/calc_scaffold.dart';
import '../../widgets/display.dart';
import '../../widgets/inputs.dart';

enum _Mode { apply, findOriginal, findRate }

class DiscountScreen extends StatefulWidget {
  const DiscountScreen({super.key});

  @override
  State<DiscountScreen> createState() => _DiscountScreenState();
}

class _DiscountScreenState extends State<DiscountScreen> {
  _Mode _mode = _Mode.apply;
  final _price = TextEditingController();
  final _rate = TextEditingController();
  final _extra = TextEditingController();
  final _finalPrice = TextEditingController();

  static const _quickRates = <double>[5, 10, 15, 20, 25, 30, 40, 50, 70];

  @override
  void dispose() {
    _price.dispose();
    _rate.dispose();
    _extra.dispose();
    _finalPrice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Discount',
      children: [
        SectionCard(
          title: 'Mode',
          children: [
            ModeSelector<_Mode>(
              selected: _mode,
              onChanged: (mode) => setState(() => _mode = mode),
              options: const [
                ModeOption(_Mode.apply, 'Apply discount'),
                ModeOption(_Mode.findOriginal, 'Find original price'),
                ModeOption(_Mode.findRate, 'Find discount %'),
              ],
            ),
          ],
        ),
        ..._inputs(),
        ..._results(),
      ],
    );
  }

  List<Widget> _inputs() {
    switch (_mode) {
      case _Mode.apply:
        return [
          SectionCard(
            title: 'Details',
            children: [
              NumberField(
                controller: _price,
                label: 'Original price',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              NumberField(
                controller: _rate,
                label: 'Discount',
                suffix: '%',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              _quickRateChips(),
              const SizedBox(height: 14),
              NumberField(
                controller: _extra,
                label: 'Extra flat amount off (optional)',
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ];

      case _Mode.findOriginal:
        return [
          SectionCard(
            title: 'Details',
            children: [
              NumberField(
                controller: _finalPrice,
                label: 'Price you paid',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              NumberField(
                controller: _rate,
                label: 'Discount that was applied',
                suffix: '%',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              _quickRateChips(),
            ],
          ),
        ];

      case _Mode.findRate:
        return [
          SectionCard(
            title: 'Details',
            children: [
              NumberField(
                controller: _price,
                label: 'Original price',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              NumberField(
                controller: _finalPrice,
                label: 'Sale price',
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ];
    }
  }

  Widget _quickRateChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final rate in _quickRates)
          ActionChip(
            label: Text('${formatNumber(rate)}%'),
            onPressed: () => setState(() {
              _rate.text = formatNumber(rate);
            }),
          ),
      ],
    );
  }

  List<Widget> _results() {
    switch (_mode) {
      case _Mode.apply:
        final price = parseNumber(_price.text);
        final rate = parseNumber(_rate.text);
        if (price == null || rate == null) {
          return [const EmptyHint('Enter a price and a discount %.')];
        }
        final extra = parseNumber(_extra.text) ?? 0;
        final discount = price * rate / 100;
        final afterDiscount = price - discount;
        final finalPrice = afterDiscount - extra;
        final saved = price - finalPrice;
        final effective = price == 0 ? 0.0 : saved / price * 100;

        return [
          ResultHero(
            label: 'You pay',
            value: formatMoney(finalPrice),
            caption: 'You save ${formatMoney(saved)} '
                '(${formatFixed(effective, 2)}% off)',
          ),
          SectionCard(
            title: 'Breakdown',
            children: [
              ResultRow(
                label: 'Original price',
                value: formatMoney(price),
              ),
              const Divider(),
              ResultRow(
                label: 'Discount (${formatNumber(rate)}%)',
                value: '- ${formatMoney(discount)}',
              ),
              if (extra != 0) ...[
                const Divider(),
                ResultRow(
                  label: 'Extra flat off',
                  value: '- ${formatMoney(extra)}',
                ),
              ],
              const Divider(),
              ResultRow(
                label: 'Final price',
                value: formatMoney(finalPrice),
                emphasise: true,
              ),
            ],
          ),
        ];

      case _Mode.findOriginal:
        final paid = parseNumber(_finalPrice.text);
        final rate = parseNumber(_rate.text);
        if (paid == null || rate == null) {
          return [const EmptyHint('Enter the price paid and the discount %.')];
        }
        if (rate >= 100) {
          return [const EmptyHint('Discount must be below 100%.')];
        }
        final original = paid / (1 - rate / 100);
        return [
          ResultHero(
            label: 'Original price',
            value: formatMoney(original),
            caption: 'You saved ${formatMoney(original - paid)}',
          ),
          SectionCard(
            title: 'Breakdown',
            children: [
              ResultRow(label: 'Price paid', value: formatMoney(paid)),
              const Divider(),
              ResultRow(
                label: 'Discount amount',
                value: formatMoney(original - paid),
              ),
            ],
          ),
        ];

      case _Mode.findRate:
        final price = parseNumber(_price.text);
        final sale = parseNumber(_finalPrice.text);
        if (price == null || sale == null) {
          return [const EmptyHint('Enter the original and sale price.')];
        }
        if (price == 0) {
          return [const EmptyHint('Original price cannot be zero.')];
        }
        final saved = price - sale;
        final percent = saved / price * 100;
        return [
          ResultHero(
            label: percent >= 0 ? 'Discount' : 'Price increase',
            value: formatFixed(percent.abs(), 2),
            unit: '%',
            caption: percent >= 0
                ? 'You save ${formatMoney(saved)}'
                : 'You pay ${formatMoney(saved.abs())} more',
          ),
        ];
    }
  }
}
