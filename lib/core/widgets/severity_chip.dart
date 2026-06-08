import 'package:flutter/material.dart';

import 'app_badge.dart';

enum SeverityLevel { info, warning, critical }

/// A specialised chip for displaying severity levels.
/// Used exclusively in Error Report and Notifications for severity labelling.
/// Defined in FRONTEND_SKILL.md Section 5.4.
class SeverityChip extends StatelessWidget {
  final SeverityLevel severity;

  const SeverityChip({
    super.key,
    required this.severity,
  });

  @override
  Widget build(BuildContext context) {
    switch (severity) {
      case SeverityLevel.info:
        return const AppBadge(
          label: 'Info',
          variant: AppBadgeVariant.blue,
        );
      case SeverityLevel.warning:
        return const AppBadge(
          label: 'Warning',
          variant: AppBadgeVariant.amber,
        );
      case SeverityLevel.critical:
        return const AppBadge(
          label: 'Critical',
          variant: AppBadgeVariant.red,
        );
    }
  }
}
