import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A custom painted circular progress ring for SOC and Capacity visualizations.
/// Defined in FRONTEND_SKILL.md Section 5.11.
class ProgressRing extends StatelessWidget {
  /// Percentage between 0.0 and 100.0
  final double percentage;
  /// Optional child widget to display in the centre of the ring
  final Widget? child;

  const ProgressRing({
    super.key,
    required this.percentage,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Ensures percentage is clamped between 0 and 100
    final targetPercentage = percentage.clamp(0.0, 100.0);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: targetPercentage),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, childWidget) {
        return CustomPaint(
          painter: _ProgressRingPainter(
            percentage: value,
          ),
          child: childWidget,
        );
      },
      child: child != null ? Center(child: child) : null,
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double percentage;

  _ProgressRingPainter({required this.percentage});

  Color _getColor(double p) {
    if (p <= 10.0) {
      return AppColors.errorRed;
    } else if (p <= 20.0) {
      return AppColors.warningAmber;
    } else {
      return AppColors.brandGreen;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 12.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    // Draw background track
    final trackPaint = Paint()
      ..color = AppColors.disabled.withValues(alpha: 0.30)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, trackPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = _getColor(percentage)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * (percentage / 100.0);
    // -pi / 2 ensures the progress starts from the top (12 o'clock)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.percentage != percentage;
  }
}
