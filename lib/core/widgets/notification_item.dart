import 'package:flutter/material.dart';

import '../../models/app_notification.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'severity_chip.dart';

/// A list tile for displaying an [AppNotification].
/// Defined in FRONTEND_SKILL.md Section 5.10.
class NotificationItem extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
  });

  /// Deduces severity from the notification title.
  SeverityLevel _getSeverity() {
    final title = notification.title.toLowerCase();
    if (title.contains('error') || title.contains('high temp')) {
      return SeverityLevel.critical;
    }
    if (title.contains('protection') || title.contains('low battery') || title.contains('warning')) {
      return SeverityLevel.warning;
    }
    return SeverityLevel.info;
  }

  IconData _getIcon(SeverityLevel severity) {
    switch (severity) {
      case SeverityLevel.info:
        return Icons.info_outline;
      case SeverityLevel.warning:
        return Icons.warning_amber_rounded;
      case SeverityLevel.critical:
        return Icons.error_outline;
    }
  }

  Color _getIconColor(SeverityLevel severity) {
    switch (severity) {
      case SeverityLevel.info:
        // Info maps to brandBlue in AppBadge, using a fallback blue here if brandBlue isn't defined, 
        // but AppColors should have a blue. We'll use a standard blue or disabled if brandBlue is missing.
        // Looking at typical setups, we'll try to use a standard material blue if brandBlue doesn't exist, 
        // but since we know AppColors has brandGreen, warningAmber, errorRed, we'll use Colors.blue for info.
        return const Color(0xFF2196F3); // Standard Material Blue for info
      case SeverityLevel.warning:
        return AppColors.warningAmber;
      case SeverityLevel.critical:
        return AppColors.errorRed;
    }
  }

  String _formatTime(DateTime time) {
    // Simple HH:MM AM/PM formatter for the spec requirement
    final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final severity = _getSeverity();
    final isUnread = !notification.read;

    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        color: isUnread ? AppColors.brandGreen.withValues(alpha: 0.05) : AppColors.surface,
        padding: const EdgeInsets.only(
          left: AppSpacing.space16,
          top: AppSpacing.space16,
          bottom: AppSpacing.space16,
          right: AppSpacing.space24,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread indicator dot
            SizedBox(
              width: 12,
              child: isUnread
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.brandGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.space8),
            // Icon
            Icon(
              _getIcon(severity),
              color: _getIconColor(severity),
              size: 24,
            ),
            const SizedBox(width: AppSpacing.space16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: AppTextStyles.labelLarge.copyWith(color: AppColors.black),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    notification.body,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkGrey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.space8),
                  Row(
                    children: [
                      Text(
                        _formatTime(notification.timestamp),
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.disabled),
                      ),
                      if (severity == SeverityLevel.warning || severity == SeverityLevel.critical) ...[
                        const SizedBox(width: AppSpacing.space12),
                        SeverityChip(severity: severity),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
