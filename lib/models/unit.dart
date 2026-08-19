import 'package:flutter/material.dart';

/// A single measurement unit.
///
/// Every unit knows how to convert to and from its category's base unit, so
/// non-linear scales (temperature, fuel economy) work exactly like linear ones.
@immutable
class Unit {
  const Unit({
    required this.id,
    required this.name,
    required this.symbol,
    required this.toBase,
    required this.fromBase,
  });

  /// A unit that is [factor] base units in size (e.g. 1 km = 1000 m).
  factory Unit.scaled(String id, String name, String symbol, double factor) {
    return Unit(
      id: id,
      name: name,
      symbol: symbol,
      toBase: (value) => value * factor,
      fromBase: (value) => value / factor,
    );
  }

  final String id;
  final String name;
  final String symbol;
  final double Function(double value) toBase;
  final double Function(double value) fromBase;

  String get label => symbol.isEmpty ? name : '$name ($symbol)';
}

/// A group of units that can be converted between each other.
@immutable
class UnitCategory {
  const UnitCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.units,
    required this.defaultFromId,
    required this.defaultToId,
    this.keywords = const <String>[],
    this.note,
  });

  final String id;
  final String name;
  final IconData icon;
  final List<Unit> units;
  final String defaultFromId;
  final String defaultToId;
  final List<String> keywords;

  /// Optional footnote shown at the bottom of the converter screen.
  final String? note;

  Unit unitById(String id) =>
      units.firstWhere((unit) => unit.id == id, orElse: () => units.first);

  /// Converts [value] from one unit of this category to another.
  double convert(double value, Unit from, Unit to) =>
      to.fromBase(from.toBase(value));
}
