import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The tools shown on the home screen out of the box. Everything else is
/// available from the "Add tools" screen, so the landing page stays short.
const List<String> kDefaultHomeTools = <String>[
  'convert_length',
  'convert_weight',
  'convert_temperature',
  'convert_volume',
  'calc_percentage',
  'calc_discount',
  'calc_age',
];

/// App-wide preferences persisted on the device with [SharedPreferences].
/// Nothing here ever touches the network.
class Settings extends ChangeNotifier {
  Settings(this._prefs);

  final SharedPreferences _prefs;

  static const _kThemeMode = 'theme_mode';
  static const _kHomeTools = 'home_tools';
  static const _kSeenWelcome = 'has_seen_welcome';

  // ---------------------------------------------------------------- theme

  ThemeMode get themeMode {
    final index = _prefs.getInt(_kThemeMode) ?? ThemeMode.system.index;
    return ThemeMode.values[index.clamp(0, ThemeMode.values.length - 1)];
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setInt(_kThemeMode, mode.index);
    notifyListeners();
  }

  /// Cycles system -> light -> dark -> system.
  Future<void> cycleThemeMode() {
    const order = <ThemeMode>[ThemeMode.system, ThemeMode.light, ThemeMode.dark];
    final next = order[(order.indexOf(themeMode) + 1) % order.length];
    return setThemeMode(next);
  }

  // -------------------------------------------------------------- welcome

  bool get hasSeenWelcome => _prefs.getBool(_kSeenWelcome) ?? false;

  Future<void> completeWelcome() => _prefs.setBool(_kSeenWelcome, true);

  // ------------------------------------------------------------ home tools

  /// Ids of the tools currently pinned to the home screen, in the order the
  /// user added them.
  List<String> get homeToolIds =>
      _prefs.getStringList(_kHomeTools) ?? kDefaultHomeTools;

  bool isOnHome(String toolId) => homeToolIds.contains(toolId);

  Future<void> addTool(String toolId) async {
    if (isOnHome(toolId)) return;
    await _prefs.setStringList(_kHomeTools, [...homeToolIds, toolId]);
    notifyListeners();
  }

  Future<void> removeTool(String toolId) async {
    final list = [...homeToolIds]..remove(toolId);
    await _prefs.setStringList(_kHomeTools, list);
    notifyListeners();
  }

  /// Puts a tool back at a specific position — used to undo a removal.
  Future<void> insertTool(String toolId, int index) async {
    final list = [...homeToolIds]..remove(toolId);
    list.insert(index.clamp(0, list.length), toolId);
    await _prefs.setStringList(_kHomeTools, list);
    notifyListeners();
  }

  /// Moves a tool within the home list, for drag-and-drop reordering.
  Future<void> reorderTools(int oldIndex, int newIndex) async {
    final list = [...homeToolIds];
    if (oldIndex < 0 || oldIndex >= list.length) return;
    // onReorderItem already adjusts newIndex for the lifted item.
    final moved = list.removeAt(oldIndex);
    list.insert(newIndex.clamp(0, list.length), moved);
    await _prefs.setStringList(_kHomeTools, list);
    notifyListeners();
  }

  Future<void> restoreDefaultTools() async {
    await _prefs.setStringList(_kHomeTools, kDefaultHomeTools);
    notifyListeners();
  }

  // ----------------------------------------------------- last used units

  String? lastUnit(String categoryId, {required bool isSource}) =>
      _prefs.getString('unit_${categoryId}_${isSource ? 'from' : 'to'}');

  Future<void> saveUnits(String categoryId, String fromId, String toId) async {
    await _prefs.setString('unit_${categoryId}_from', fromId);
    await _prefs.setString('unit_${categoryId}_to', toId);
  }
}

/// Makes [Settings] available to the widget tree and rebuilds listeners.
class SettingsScope extends InheritedNotifier<Settings> {
  const SettingsScope({
    super.key,
    required Settings settings,
    required super.child,
  }) : super(notifier: settings);

  static Settings of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SettingsScope>();
    assert(scope != null, 'SettingsScope is missing above this widget.');
    return scope!.notifier!;
  }
}
