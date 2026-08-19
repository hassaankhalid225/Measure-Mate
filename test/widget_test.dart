import 'package:everyday_calculator/core/settings.dart';
import 'package:everyday_calculator/main.dart';
import 'package:everyday_calculator/models/tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pumps the app past the welcome screen, on the default set of home tools,
/// and returns the live [Settings] so tests can assert on stored state
/// instead of on what happens to be scrolled into view.
Future<Settings> pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    'has_seen_welcome': true,
  });
  final prefs = await SharedPreferences.getInstance();
  final settings = Settings(prefs);
  await tester.pumpWidget(
    EverydayApp(settings: settings, showWelcome: !settings.hasSeenWelcome),
  );
  await tester.pumpAndSettle();
  return settings;
}

/// The page itself, not the scrollable inside a text field.
Finder get pageScrollable => find.byType(Scrollable).first;

void main() {
  testWidgets('first launch shows the welcome screen', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final settings = Settings(prefs);
    await tester.pumpWidget(
      EverydayApp(settings: settings, showWelcome: !settings.hasSeenWelcome),
    );
    await tester.pumpAndSettle();

    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('Works offline'), findsOneWidget);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    // Landed on the home screen, and the choice was remembered.
    expect(find.text('Measure Mate'), findsOneWidget);
    expect(find.text('Get started'), findsNothing);
    expect(settings.hasSeenWelcome, isTrue);
  });

  testWidgets('home shows only the default tools, not everything',
      (tester) async {
    await pumpApp(tester);

    expect(find.text('Measure Mate'), findsOneWidget);
    expect(find.text('Length'), findsOneWidget);
    expect(find.text('Percentage'), findsOneWidget);

    // Not in the default set - must be added deliberately.
    expect(find.text('Pressure'), findsNothing);
    expect(find.text('Frequency'), findsNothing);
  });

  testWidgets('search still finds tools that are not on the home screen',
      (tester) async {
    await pumpApp(tester);

    await tester.enterText(find.byType(TextField).first, 'psi');
    await tester.pumpAndSettle();

    expect(find.text('Pressure'), findsOneWidget);
    expect(find.text('Length'), findsNothing);
  });

  testWidgets('a converter can be added from the dropdown', (tester) async {
    await pumpApp(tester);

    await tester.scrollUntilVisible(
      find.text('Add or remove tools'),
      300,
      scrollable: pageScrollable,
    );
    await tester.tap(find.text('Add or remove tools'));
    await tester.pumpAndSettle();

    // Pick "Pressure" from the converters dropdown.
    await tester.tap(find.byType(DropdownButtonFormField<Tool>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pressure').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add to home').first);
    await tester.pumpAndSettle();

    // Back on home, the new tool is listed.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Pressure'), findsOneWidget);
  });

  testWidgets('a converter can be removed from home and undone',
      (tester) async {
    final settings = await pumpApp(tester);
    expect(find.text('Length'), findsOneWidget);

    await tester.tap(find.byTooltip('Edit home screen'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Remove Length from home'));
    await tester.pumpAndSettle();

    expect(find.text('Length'), findsNothing);
    expect(settings.isOnHome('convert_length'), isFalse);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Length'), findsOneWidget);
    // Restored to its original position, not appended to the end.
    expect(settings.homeToolIds.indexOf('convert_length'), 0);
  });

  testWidgets('a calculator can be removed from home too', (tester) async {
    final settings = await pumpApp(tester);
    expect(settings.isOnHome('calc_age'), isTrue);

    await tester.tap(find.byTooltip('Edit home screen'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byTooltip('Remove Age from home'),
      200,
      scrollable: pageScrollable,
    );
    await tester.tap(find.byTooltip('Remove Age from home'));
    await tester.pumpAndSettle();

    expect(settings.isOnHome('calc_age'), isFalse);

    // Leaving edit mode keeps the removal.
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(settings.isOnHome('calc_age'), isFalse);
  });

  testWidgets('length converter shows a live result', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Length'));
    await tester.pumpAndSettle();

    // Defaults to 1 metre -> feet.
    expect(find.textContaining('3.280839895'), findsWidgets);
  });

  testWidgets('percentage calculator computes 15% of 200', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Percentage'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '15');
    await tester.enterText(fields.at(1), '200');
    await tester.pumpAndSettle();

    expect(find.text('30'), findsOneWidget);
  });

  testWidgets('EMI calculator handles a zero-interest loan', (tester) async {
    await pumpApp(tester);

    await tester.enterText(find.byType(TextField).first, 'emi');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Loan EMI'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '120000'); // amount
    await tester.enterText(fields.at(1), '0'); // rate
    await tester.enterText(fields.at(2), '1'); // 1 year
    await tester.pumpAndSettle();

    // 120,000 over 12 months at 0% is exactly 10,000 a month.
    expect(find.text('10,000.00'), findsOneWidget);
  });

  testWidgets('tip calculator splits a bill between people', (tester) async {
    await pumpApp(tester);

    await tester.enterText(find.byType(TextField).first, 'tip');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tip & split'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '1000'); // bill
    await tester.enterText(fields.at(1), '10'); // tip %
    await tester.pumpAndSettle();

    // Shown twice: once as the headline, once in the breakdown.
    expect(find.text('1,100.00'), findsNWidgets(2));

    // Split four ways: 1,100 / 4 = 275.
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
    }
    expect(find.text('275.00'), findsOneWidget);
  });

  testWidgets('number base converter shows every base', (tester) async {
    await pumpApp(tester);

    await tester.enterText(find.byType(TextField).first, 'hex');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Number base'));
    await tester.pumpAndSettle();

    // Defaults to 255 in decimal.
    expect(find.text('FF'), findsOneWidget);
    expect(find.text('377'), findsOneWidget);
    expect(find.text('11111111'), findsOneWidget);
    expect(find.text('0xFF'), findsOneWidget);
  });
}
