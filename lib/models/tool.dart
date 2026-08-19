import 'package:flutter/material.dart';

enum ToolKind { converter, calculator }

/// An entry on the home screen: either a unit converter or a calculator.
@immutable
class Tool {
  const Tool({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.kind,
    required this.builder,
    this.keywords = const <String>[],
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final ToolKind kind;
  final List<String> keywords;
  final WidgetBuilder builder;

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    if (title.toLowerCase().contains(needle)) return true;
    if (subtitle.toLowerCase().contains(needle)) return true;
    return keywords.any((keyword) => keyword.contains(needle));
  }
}
