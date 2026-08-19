import 'package:flutter/material.dart';

import '../core/settings.dart';
import '../core/theme.dart';
import 'home_screen.dart';

/// Shown once, on the very first launch.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const _points = <(IconData, String, String)>[
    (
      Icons.swap_horiz,
      'Convert anything',
      'Length, weight, temperature and more — results update as you type.',
    ),
    (
      Icons.calculate_outlined,
      'Everyday maths',
      'Percentages, discounts, tax, age and dates, without the guesswork.',
    ),
    (
      Icons.cloud_off,
      'Works offline',
      'No internet, no accounts. Nothing ever leaves your device.',
    ),
  ];

  Future<void> _start(BuildContext context) async {
    final navigator = Navigator.of(context);
    await SettingsScope.of(context).completeWelcome();
    navigator.pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              Text(
                'Measure\nMate',
                style: context.texts.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Converters and calculators for the things you actually '
                'work out every day.',
                style: context.texts.titleMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const Spacer(flex: 2),
              for (final (icon, title, body) in _points) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 22),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, size: 24, color: context.colors.primary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: context.texts.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              body,
                              style: context.texts.bodyMedium?.copyWith(
                                color: context.colors.onSurfaceVariant,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _start(context),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Get started'),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'You can add or remove tools any time.',
                  style: context.texts.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
