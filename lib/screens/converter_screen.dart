import 'package:flutter/material.dart';

import '../core/formatting.dart';
import '../core/settings.dart';
import '../core/theme.dart';
import '../models/unit.dart';
import '../widgets/display.dart';
import '../widgets/inputs.dart';

/// Live converter for a single [UnitCategory].
class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key, required this.category});

  final UnitCategory category;

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final TextEditingController _input = TextEditingController(text: '1');
  late Unit _from;
  late Unit _to;
  bool _restored = false;

  UnitCategory get _category => widget.category;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_restored) return;
    _restored = true;

    final settings = SettingsScope.of(context);
    _from = _category.unitById(
      settings.lastUnit(_category.id, isSource: true) ?? _category.defaultFromId,
    );
    _to = _category.unitById(
      settings.lastUnit(_category.id, isSource: false) ?? _category.defaultToId,
    );
    _input.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _input.text.length,
    );
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _persist() {
    SettingsScope.of(context).saveUnits(_category.id, _from.id, _to.id);
  }

  void _swap() {
    setState(() {
      final previous = _from;
      _from = _to;
      _to = previous;
    });
    _persist();
  }

  Future<void> _selectUnit({required bool isSource}) async {
    final picked = await showModalBottomSheet<Unit>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _UnitPickerSheet(
        category: _category,
        selected: isSource ? _from : _to,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isSource) {
        _from = picked;
      } else {
        _to = picked;
      }
    });
    _persist();
  }

  @override
  Widget build(BuildContext context) {
    final value = parseNumber(_input.text);
    final result = value == null ? null : _category.convert(value, _from, _to);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(title: Text(_category.name)),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              SectionCard(
                title: 'From',
                children: [
                  _UnitButton(
                    unit: _from,
                    onTap: () => _selectUnit(isSource: true),
                  ),
                  const SizedBox(height: 12),
                  NumberField(
                    controller: _input,
                    label: 'Value',
                    allowNegative: true,
                    autofocus: true,
                    suffix: _from.symbol,
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: TextButton.icon(
                    onPressed: _swap,
                    icon: const Icon(Icons.swap_vert, size: 18),
                    label: const Text('Swap'),
                  ),
                ),
              ),
              SectionCard(
                title: 'To',
                children: [
                  _UnitButton(
                    unit: _to,
                    onTap: () => _selectUnit(isSource: false),
                  ),
                  const SizedBox(height: 12),
                  if (result == null)
                    const EmptyHint('Enter a value to convert.')
                  else
                    ResultHero(
                      label: 'Result',
                      value: formatNumberGrouped(result),
                      unit: _to.symbol,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              SectionCard(
                title: 'Rate',
                children: [
                  ResultRow(
                    label: '1 ${_from.name.toLowerCase()}',
                    value: '${formatNumber(_category.convert(1, _from, _to))} '
                        '${_to.symbol}',
                  ),
                  const Divider(),
                  ResultRow(
                    label: '1 ${_to.name.toLowerCase()}',
                    value: '${formatNumber(_category.convert(1, _to, _from))} '
                        '${_from.symbol}',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SectionCard(
                title: 'All units',
                children: [
                  if (value == null)
                    const EmptyHint('Enter a value to see every unit.')
                  else
                    for (var i = 0; i < _category.units.length; i++) ...[
                      if (i > 0) const Divider(),
                      _AllUnitsRow(
                        unit: _category.units[i],
                        value: _category.convert(
                          value,
                          _from,
                          _category.units[i],
                        ),
                        highlighted: _category.units[i].id == _to.id,
                      ),
                    ],
                  if (_category.note != null) InfoNote(_category.note!),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-width button that opens the unit picker.
class _UnitButton extends StatelessWidget {
  const _UnitButton({required this.unit, required this.onTap});

  final Unit unit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        alignment: Alignment.centerLeft,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              unit.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.expand_more, size: 20),
        ],
      ),
    );
  }
}

class _AllUnitsRow extends StatelessWidget {
  const _AllUnitsRow({
    required this.unit,
    required this.value,
    required this.highlighted,
  });

  final Unit unit;
  final double value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final text = formatNumberGrouped(value);
    return InkWell(
      onTap: () => copyValue(context, text, label: unit.name),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
        child: Row(
          children: [
            Expanded(
              child: Text(
                unit.label,
                style: context.texts.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.end,
                style: context.texts.bodyLarge?.copyWith(
                  fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Searchable list of the units in a category.
class _UnitPickerSheet extends StatefulWidget {
  const _UnitPickerSheet({required this.category, required this.selected});

  final UnitCategory category;
  final Unit selected;

  @override
  State<_UnitPickerSheet> createState() => _UnitPickerSheetState();
}

class _UnitPickerSheetState extends State<_UnitPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final needle = _query.trim().toLowerCase();
    final units = widget.category.units
        .where(
          (unit) =>
              needle.isEmpty ||
              unit.name.toLowerCase().contains(needle) ||
              unit.symbol.toLowerCase().contains(needle),
        )
        .toList(growable: false);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search units',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (text) => setState(() => _query = text),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: units.length,
                itemBuilder: (context, index) {
                  final unit = units[index];
                  final isSelected = unit.id == widget.selected.id;
                  return ListTile(
                    title: Text(unit.name),
                    subtitle: Text(unit.symbol),
                    selected: isSelected,
                    trailing: isSelected ? const Icon(Icons.check) : null,
                    onTap: () => Navigator.of(context).pop(unit),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
