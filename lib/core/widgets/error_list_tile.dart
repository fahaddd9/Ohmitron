import 'package:flutter/material.dart';

import '../../models/error_entry.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'severity_chip.dart';

/// A list tile for displaying an [ErrorEntry] from the BMS history.
/// Defined in FRONTEND_SKILL.md Section 5.15.
class ErrorListTile extends StatelessWidget {
  final ErrorEntry errorEntry;

  const ErrorListTile({
    super.key,
    required this.errorEntry,
  });

  SeverityLevel _parseSeverity(String severityString) {
    switch (severityString.toLowerCase()) {
      case 'critical':
        return SeverityLevel.critical;
      case 'warning':
        return SeverityLevel.warning;
      case 'info':
      default:
        return SeverityLevel.info;
    }
  }

  String _formatTimestamp(DateTime time) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[time.month - 1];
    final day = time.day;
    final year = time.year;
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    
    return '$month $day, $year - $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.background,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                errorEntry.errorCode,
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.black),
              ),
              SeverityChip(severity: _parseSeverity(errorEntry.severity)),
            ],
          ),
          const SizedBox(height: AppSpacing.space8),
          Text(
            errorEntry.message,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkGrey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.space8),
          Text(
            _formatTimestamp(errorEntry.timestamp),
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.disabled),
          ),
        ],
      ),
    );
  }
}
