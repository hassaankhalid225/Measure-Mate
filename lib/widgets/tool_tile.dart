import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/tool.dart';

/// One row on the home screen, also used for search results.
class ToolTile extends StatelessWidget {
  const ToolTile({
    super.key,
    required this.tool,
    required this.onTap,
    this.trailing,
  });

  final Tool tool;

  /// Null while the home screen is in edit mode, so rows can't be opened
  /// by accident while removing them.
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(tool.icon, color: context.colors.onSurfaceVariant),
      title: Text(
        tool.title,
        style: context.texts.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(tool.subtitle),
      trailing: trailing ??
          Icon(
            Icons.chevron_right,
            color: context.colors.onSurfaceVariant,
          ),
    );
  }
}
