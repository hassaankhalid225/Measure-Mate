import 'package:flutter/material.dart';

import '../core/settings.dart';
import '../core/theme.dart';
import '../data/tools.dart';
import '../models/tool.dart';
import '../widgets/tool_tile.dart';
import 'add_tools_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  bool _editing = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _open(Tool tool) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: tool.builder));
  }

  Future<void> _openAddTools() {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AddToolsScreen()));
  }

  /// Removes a tool from the home screen, offering an undo that restores it
  /// to the same position.
  void _remove(Tool tool) {
    final settings = SettingsScope.of(context);
    final index = settings.homeToolIds.indexOf(tool.id);
    if (index < 0) return;

    settings.removeTool(tool.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${tool.title} removed'),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => settings.insertTool(tool.id, index),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.of(context);
    final isSearching = _query.trim().isNotEmpty;

    final myTools = settings.homeToolIds
        .map(toolById)
        .whereType<Tool>()
        .toList(growable: false);
    final converters = myTools
        .where((t) => t.kind == ToolKind.converter)
        .toList();
    final calculators = myTools
        .where((t) => t.kind == ToolKind.calculator)
        .toList();

    // Leaving edit mode automatically keeps the two modes from tangling.
    final editing = _editing && !isSearching && myTools.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Measure Mate'),
        actions: [
          if (!isSearching && myTools.isNotEmpty)
            editing
                ? TextButton(
                    onPressed: () => setState(() => _editing = false),
                    child: const Text('Done'),
                  )
                : IconButton(
                    tooltip: 'Edit home screen',
                    onPressed: () => setState(() => _editing = true),
                    icon: const Icon(Icons.edit_outlined),
                  ),
          IconButton(
            tooltip: 'Theme: ${settings.themeMode.name}',
            onPressed: settings.cycleThemeMode,
            icon: Icon(switch (settings.themeMode) {
              ThemeMode.system => Icons.brightness_auto_outlined,
              ThemeMode.light => Icons.light_mode_outlined,
              ThemeMode.dark => Icons.dark_mode_outlined,
            }),
          ),
          IconButton(
            tooltip: 'About',
            onPressed: _showAbout,
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      // SafeArea keeps content clear of the gesture bar now that Android 15+
      // forces edge-to-edge for apps targeting SDK 35 and above.
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: TextField(
                controller: _search,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search a unit or tool',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _search.clear();
                            setState(() => _query = '');
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                        ),
                ),
                onChanged: (text) => setState(() {
                  _query = text;
                  if (text.trim().isNotEmpty) _editing = false;
                }),
              ),
            ),
            if (isSearching)
              ..._searchResults()
            else ...[
              if (editing)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                  child: Text(
                    'Tap the minus to take a tool off your home screen.',
                    style: context.texts.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
              if (myTools.isEmpty)
                _emptyState()
              else ...[
                if (converters.isNotEmpty) ...[
                  _header('Converters'),
                  for (final tool in converters) _homeTile(tool, editing),
                ],
                if (calculators.isNotEmpty) ...[
                  _header('Calculators'),
                  for (final tool in calculators) _homeTile(tool, editing),
                ],
              ],
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _openAddTools,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Add or remove tools'),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Works offline. Nothing leaves your device.',
                  textAlign: TextAlign.center,
                  style: context.texts.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _homeTile(Tool tool, bool editing) {
    return ToolTile(
      tool: tool,
      onTap: editing ? null : () => _open(tool),
      trailing: editing
          ? IconButton(
              tooltip: 'Remove ${tool.title} from home',
              icon: const Icon(Icons.remove_circle_outline),
              color: context.colors.error,
              onPressed: () => _remove(tool),
            )
          : null,
    );
  }

  List<Widget> _searchResults() {
    final settings = SettingsScope.of(context);
    final results = searchTools(_query);

    if (results.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
          child: Text(
            'Nothing matches "$_query".',
            textAlign: TextAlign.center,
            style: context.texts.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
      ];
    }

    return [
      for (final tool in results)
        ToolTile(
          tool: tool,
          onTap: () => _open(tool),
          trailing: settings.isOnHome(tool.id)
              ? IconButton(
                  tooltip: 'Remove ${tool.title} from home',
                  icon: const Icon(Icons.remove_circle_outline),
                  color: context.colors.error,
                  onPressed: () => _remove(tool),
                )
              : IconButton(
                  tooltip: 'Add ${tool.title} to home',
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => settings.addTool(tool.id),
                ),
        ),
    ];
  }

  Widget _header(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        title,
        style: context.texts.titleSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: context.colors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 8),
      child: Column(
        children: [
          Text(
            'Your home screen is empty',
            style: context.texts.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add the converters and calculators you use.',
            textAlign: TextAlign.center,
            style: context.texts.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Measure Mate',
      applicationVersion: '0.2',
      children: const [
        SizedBox(height: 8),
        Text(
          '16 converters and 9 everyday calculators. Fully offline — no '
          'network permission is used and nothing is uploaded anywhere.',
        ),
      ],
    );
  }
}
