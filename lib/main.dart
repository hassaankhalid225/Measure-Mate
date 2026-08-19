import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/settings.dart';
import 'core/theme.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final settings = Settings(prefs);
  runApp(
    EverydayApp(
      settings: settings,
      // Decided once at launch so the welcome screen cannot reappear when
      // settings change mid-session.
      showWelcome: !settings.hasSeenWelcome,
    ),
  );
}

class EverydayApp extends StatelessWidget {
  const EverydayApp({
    super.key,
    required this.settings,
    this.showWelcome = false,
  });

  final Settings settings;
  final bool showWelcome;

  @override
  Widget build(BuildContext context) {
    return SettingsScope(
      settings: settings,
      child: AnimatedBuilder(
        animation: settings,
        builder: (context, _) => MaterialApp(
          title: 'Measure Mate',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settings.themeMode,
          home: showWelcome ? const WelcomeScreen() : const HomeScreen(),
        ),
      ),
    );
  }
}
