import 'package:flutter/material.dart';

import '../models/tool.dart';
import '../screens/calculators/age_screen.dart';
import '../screens/calculators/bmi_screen.dart';
import '../screens/calculators/date_difference_screen.dart';
import '../screens/calculators/discount_screen.dart';
import '../screens/calculators/emi_screen.dart';
import '../screens/calculators/fuel_screen.dart';
import '../screens/calculators/gst_screen.dart';
import '../screens/calculators/percentage_screen.dart';
import '../screens/calculators/tip_screen.dart';
import '../screens/converter_screen.dart';
import '../screens/number_base_screen.dart';
import 'unit_categories.dart';

/// Every converter. The unit-based ones are derived from the unit data so the
/// two never drift apart; number base needs its own screen because bases are
/// not a linear scale.
final List<Tool> kConverterTools = <Tool>[
  ...kUnitCategories.map((category) {
    return Tool(
      id: 'convert_${category.id}',
      title: category.name,
      subtitle: '${category.units.length} units',
      icon: category.icon,
      kind: ToolKind.converter,
      keywords: <String>[
        ...category.keywords,
        for (final unit in category.units) unit.name.toLowerCase(),
        for (final unit in category.units) unit.symbol.toLowerCase(),
      ],
      builder: (context) => ConverterScreen(category: category),
    );
  }),
  Tool(
    id: 'convert_number_base',
    title: 'Number base',
    subtitle: 'Binary, octal, hex',
    icon: Icons.tag,
    kind: ToolKind.converter,
    keywords: const [
      'binary',
      'octal',
      'hexadecimal',
      'hex',
      'decimal',
      'base',
      'bits',
      'radix',
    ],
    builder: (context) => const NumberBaseScreen(),
  ),
];

final List<Tool> kCalculatorTools = <Tool>[
  Tool(
    id: 'calc_percentage',
    title: 'Percentage',
    subtitle: 'Of, change, ± %',
    icon: Icons.percent,
    kind: ToolKind.calculator,
    keywords: const ['percent', 'increase', 'decrease', 'ratio', 'marks'],
    builder: (context) => const PercentageScreen(),
  ),
  Tool(
    id: 'calc_discount',
    title: 'Discount',
    subtitle: 'Sale price & savings',
    icon: Icons.local_offer_outlined,
    kind: ToolKind.calculator,
    keywords: const ['sale', 'offer', 'off', 'shopping', 'mrp', 'deal'],
    builder: (context) => const DiscountScreen(),
  ),
  Tool(
    id: 'calc_gst',
    title: 'GST / Tax',
    subtitle: 'Add or remove tax',
    icon: Icons.receipt_long_outlined,
    kind: ToolKind.calculator,
    keywords: const ['vat', 'sales tax', 'invoice', 'cgst', 'sgst', 'igst'],
    builder: (context) => const GstScreen(),
  ),
  Tool(
    id: 'calc_emi',
    title: 'Loan EMI',
    subtitle: 'Instalment & interest',
    icon: Icons.account_balance_outlined,
    kind: ToolKind.calculator,
    keywords: const [
      'emi',
      'loan',
      'instalment',
      'installment',
      'interest',
      'mortgage',
      'finance',
      'car loan',
      'home loan',
    ],
    builder: (context) => const EmiScreen(),
  ),
  Tool(
    id: 'calc_tip',
    title: 'Tip & split',
    subtitle: 'Split a bill',
    icon: Icons.restaurant_outlined,
    kind: ToolKind.calculator,
    keywords: const [
      'tip',
      'split',
      'bill',
      'restaurant',
      'service charge',
      'share',
    ],
    builder: (context) => const TipScreen(),
  ),
  Tool(
    id: 'calc_fuel',
    title: 'Fuel cost',
    subtitle: 'Mileage & trip cost',
    icon: Icons.local_gas_station_outlined,
    kind: ToolKind.calculator,
    keywords: const ['petrol', 'diesel', 'mileage', 'kmpl', 'average', 'trip'],
    builder: (context) => const FuelScreen(),
  ),
  Tool(
    id: 'calc_age',
    title: 'Age',
    subtitle: 'Exact age & birthday',
    icon: Icons.cake_outlined,
    kind: ToolKind.calculator,
    keywords: const ['birthday', 'dob', 'born', 'years old'],
    builder: (context) => const AgeScreen(),
  ),
  Tool(
    id: 'calc_bmi',
    title: 'BMI',
    subtitle: 'Body mass index',
    icon: Icons.monitor_heart_outlined,
    kind: ToolKind.calculator,
    keywords: const ['body mass', 'weight', 'health', 'fitness', 'obese'],
    builder: (context) => const BmiScreen(),
  ),
  Tool(
    id: 'calc_date_diff',
    title: 'Date difference',
    subtitle: 'Days between dates',
    icon: Icons.date_range_outlined,
    kind: ToolKind.calculator,
    keywords: const ['days between', 'deadline', 'working days', 'calendar'],
    builder: (context) => const DateDifferenceScreen(),
  ),
];

final List<Tool> kAllTools = <Tool>[...kConverterTools, ...kCalculatorTools];

Tool? toolById(String id) {
  for (final tool in kAllTools) {
    if (tool.id == id) return tool;
  }
  return null;
}

List<Tool> searchTools(String query) =>
    kAllTools.where((tool) => tool.matches(query)).toList(growable: false);
