import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/formatting.dart';

/// A plain numeric text field.
class NumberField extends StatelessWidget {
  const NumberField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefix,
    this.suffix,
    this.helper,
    this.allowNegative = false,
    this.autofocus = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? prefix;
  final String? suffix;
  final String? helper;
  final bool allowNegative;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: TextInputType.numberWithOptions(
        decimal: true,
        signed: allowNegative,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(allowNegative ? r'[0-9.\-]' : r'[0-9.]'),
        ),
      ],
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helper,
        prefixText: prefix,
        suffixText: suffix,
      ),
      onChanged: onChanged,
    );
  }
}

/// A tappable field that opens the platform date picker.
class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: firstDate ?? DateTime(1900),
          lastDate: lastDate ?? DateTime(2200, 12, 31),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Text(formatDate(value)),
      ),
    );
  }
}

/// One selectable mode inside a [ModeSelector].
@immutable
class ModeOption<T> {
  const ModeOption(this.value, this.label);

  final T value;
  final String label;
}

/// A wrapping row of choice chips. Wraps instead of overflowing on
/// narrow screens.
class ModeSelector<T> extends StatelessWidget {
  const ModeSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<ModeOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          ChoiceChip(
            label: Text(option.label),
            selected: option.value == selected,
            onSelected: (_) => onChanged(option.value),
          ),
      ],
    );
  }
}
