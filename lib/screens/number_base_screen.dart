import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/formatting.dart';
import '../widgets/calc_scaffold.dart';
import '../widgets/display.dart';
import '../widgets/inputs.dart';

class _Base {
  const _Base(this.radix, this.name, this.pattern);

  final int radix;
  final String name;

  /// Characters that are valid digits in this base.
  final String pattern;
}

const _bases = <_Base>[
  _Base(2, 'Binary', r'[01]'),
  _Base(8, 'Octal', r'[0-7]'),
  _Base(10, 'Decimal', r'[0-9]'),
  _Base(16, 'Hexadecimal', r'[0-9a-fA-F]'),
];

/// Converts a whole number between binary, octal, decimal and hexadecimal.
///
/// Bases are not a linear scale, so this cannot use the unit converter.
class NumberBaseScreen extends StatefulWidget {
  const NumberBaseScreen({super.key});

  @override
  State<NumberBaseScreen> createState() => _NumberBaseScreenState();
}

class _NumberBaseScreenState extends State<NumberBaseScreen> {
  final _input = TextEditingController(text: '255');
  _Base _base = _bases[2];

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _changeBase(_Base next) {
    // Carry the current value across instead of leaving invalid digits behind.
    final current = int.tryParse(_input.text.trim(), radix: _base.radix);
    setState(() {
      _base = next;
      if (current != null) {
        _input.text = current.toRadixString(next.radix).toUpperCase();
      } else {
        _input.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = _input.text.trim();
    final value = text.isEmpty ? null : int.tryParse(text, radix: _base.radix);

    return CalcScaffold(
      title: 'Number base',
      children: [
        SectionCard(
          title: 'Input',
          children: [
            ModeSelector<_Base>(
              selected: _base,
              onChanged: _changeBase,
              options: [
                for (final base in _bases)
                  ModeOption(base, '${base.name} (${base.radix})'),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _input,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              keyboardType: _base.radix == 16
                  ? TextInputType.text
                  : const TextInputType.numberWithOptions(),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(_base.pattern)),
              ],
              decoration: InputDecoration(
                labelText: '${_base.name} value',
                hintText: 'Digits allowed: ${_allowedDigits(_base)}',
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
        if (text.isEmpty)
          const EmptyHint('Enter a number to convert.')
        else if (value == null)
          const EmptyHint(
            'That value is too large to convert. The maximum is a 64-bit '
            'signed integer (9,223,372,036,854,775,807).',
          )
        else
          ..._results(value),
      ],
    );
  }

  List<Widget> _results(int value) {
    return [
      SectionCard(
        title: 'All bases',
        children: [
          for (var i = 0; i < _bases.length; i++) ...[
            if (i > 0) const Divider(),
            ResultRow(
              label: '${_bases[i].name} (base ${_bases[i].radix})',
              value: _bases[i].radix == 10
                  ? groupDigits(value.toString())
                  : value.toRadixString(_bases[i].radix).toUpperCase(),
              emphasise: _bases[i].radix == _base.radix,
            ),
          ],
        ],
      ),
      SectionCard(
        title: 'Details',
        children: [
          ResultRow(
            label: 'Bits needed',
            value: plural(value == 0 ? 1 : value.toRadixString(2).length, 'bit'),
          ),
          const Divider(),
          ResultRow(
            label: 'Bytes needed',
            value: plural(
              ((value == 0 ? 1 : value.toRadixString(2).length) + 7) ~/ 8,
              'byte',
            ),
          ),
          const Divider(),
          ResultRow(
            label: 'Hex with prefix',
            value: '0x${value.toRadixString(16).toUpperCase()}',
          ),
          const Divider(),
          ResultRow(
            label: 'Binary, grouped',
            value: _groupBits(value.toRadixString(2)),
          ),
        ],
      ),
    ];
  }

  String _allowedDigits(_Base base) {
    switch (base.radix) {
      case 2:
        return '0-1';
      case 8:
        return '0-7';
      case 16:
        return '0-9, A-F';
      default:
        return '0-9';
    }
  }

  /// `11111111` -> `1111 1111`, counted from the right.
  String _groupBits(String bits) {
    final buffer = StringBuffer();
    for (var i = 0; i < bits.length; i++) {
      if (i > 0 && (bits.length - i) % 4 == 0) buffer.write(' ');
      buffer.write(bits[i]);
    }
    return buffer.toString();
  }
}
