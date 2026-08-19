import 'package:everyday_calculator/core/settings.dart';
import 'package:everyday_calculator/data/tools.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Settings> settingsWith(List<String> tools) async {
  SharedPreferences.setMockInitialValues(<String, Object>{'home_tools': tools});
  return Settings(await SharedPreferences.getInstance());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('home tool list', () {
    test('reorder moves a tool down', () async {
      final settings = await settingsWith(['a', 'b', 'c']);
      await settings.reorderTools(0, 2);
      expect(settings.homeToolIds, ['b', 'c', 'a']);
    });

    test('reorder moves a tool up', () async {
      final settings = await settingsWith(['a', 'b', 'c']);
      await settings.reorderTools(2, 0);
      expect(settings.homeToolIds, ['c', 'a', 'b']);
    });

    test('reorder ignores an out-of-range index', () async {
      final settings = await settingsWith(['a', 'b']);
      await settings.reorderTools(5, 0);
      expect(settings.homeToolIds, ['a', 'b']);
    });

    test('add is idempotent and remove works', () async {
      final settings = await settingsWith(['a']);
      await settings.addTool('b');
      await settings.addTool('b');
      expect(settings.homeToolIds, ['a', 'b']);
      await settings.removeTool('a');
      expect(settings.homeToolIds, ['b']);
    });

    test('undo restores a tool to its original slot', () async {
      final settings = await settingsWith(['a', 'b', 'c']);
      await settings.removeTool('b');
      expect(settings.homeToolIds, ['a', 'c']);
      await settings.insertTool('b', 1);
      expect(settings.homeToolIds, ['a', 'b', 'c']);
    });

    test('reset restores the shipped defaults', () async {
      final settings = await settingsWith(['a']);
      await settings.restoreDefaultTools();
      expect(settings.homeToolIds, kDefaultHomeTools);
      for (final id in settings.homeToolIds) {
        expect(toolById(id), isNotNull);
      }
    });
  });
}
