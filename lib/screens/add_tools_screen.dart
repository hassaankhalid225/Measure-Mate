import 'package:flutter/material.dart';

import '../core/settings.dart';
import '../core/theme.dart';
import '../data/tools.dart';
import '../models/tool.dart';
import '../widgets/display.dart';

/// Lets the user build their own home screen: pick any converter or
/// calculator from a dropdown and add it, or remove what they don't use.
class AddToolsScreen extends StatefulWidget {
  const AddToolsScreen({super.key});

  @override
  State<AddToolsScreen> createState() => _AddToolsScreenState();
}

class _AddToolsScreenState extends State<AddToolsScreen> {
  Tool? _converter;
  Tool? _calculator;

  @override
  void initState() {
    super.initState();
    _converter = kConverterTools.first;
    _calculator = kCalculatorTools.first;
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.of(context);
    final onHome = settings.homeToolIds
        .map(toolById)
        .whereType<Tool>()
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add tools'),
        actions: [
          TextButton(
            onPressed: settings.restoreDefaultTools,
            child: const Text('Reset'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _picker(
              title: 'Converters',
              hint: 'All ${kConverterTools.length} converters',
              tools: kConverterTools,
              selected: _converter,
              onSelected: (tool) => setState(() => _converter = tool),
              settings: settings,
            ),
            const SizedBox(height: 12),
            _picker(
              title: 'Calculators',
              hint: 'All ${kCalculatorTools.length} calculators',
              tools: kCalculatorTools,
              selected: _calculator,
              onSelected: (tool) => setState(() => _calculator = tool),
              settings: settings,
            ),
            const SizedBox(height: 12),
            SectionCard(
              title: 'On your home screen',
              children: [
                if (onHome.isEmpty)
                  const EmptyHint('Nothing added yet. Pick a tool above.')
                else ...[
                  const InfoNote('Drag the handle to change the order.'),
                  const SizedBox(height: 4),
                  ReorderableListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    onReorderItem: settings.reorderTools,
                    children: [
                      for (var i = 0; i < onHome.length; i++)
                        ListTile(
                          key: ValueKey<String>(onHome[i].id),
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            onHome[i].icon,
                            color: context.colors.onSurfaceVariant,
                          ),
                          title: Text(
                            onHome[i].title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Remove ${onHome[i].title}',
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () =>
                                    settings.removeTool(onHome[i].id),
                              ),
                              ReorderableDragStartListener(
                                index: i,
                                child: Icon(
                                  Icons.drag_handle,
                                  color: context.colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _picker({
    required String title,
    required String hint,
    required List<Tool> tools,
    required Tool? selected,
    required ValueChanged<Tool?> onSelected,
    required Settings settings,
  }) {
    final alreadyAdded = selected != null && settings.isOnHome(selected.id);

    return SectionCard(
      title: title,
      children: [
        DropdownButtonFormField<Tool>(
          initialValue: selected,
          isExpanded: true,
          decoration: InputDecoration(labelText: hint),
          items: [
            for (final tool in tools)
              DropdownMenuItem<Tool>(
                value: tool,
                child: Row(
                  children: [
                    Icon(
                      tool.icon,
                      size: 20,
                      color: context.colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tool.title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (settings.isOnHome(tool.id))
                      Icon(
                        Icons.check,
                        size: 18,
                        color: context.colors.primary,
                      ),
                  ],
                ),
              ),
          ],
          onChanged: onSelected,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: selected == null || alreadyAdded
                ? null
                : () {
                    settings.addTool(selected.id);
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text('${selected.title} added to home'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                  },
            icon: const Icon(Icons.add),
            label: Text(alreadyAdded ? 'Already on home' : 'Add to home'),
          ),
        ),
      ],
    );
  }
}
