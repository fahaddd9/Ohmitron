import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AnimatedScanWidget extends StatefulWidget {
  const AnimatedScanWidget({super.key});

  @override
  State<AnimatedScanWidget> createState() => _AnimatedScanWidgetState();
}

class _AnimatedScanWidgetState extends State<AnimatedScanWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;

  @override
  void initState() {
    super.initState();

    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _controller3 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _controller2.repeat();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _controller3.repeat();
    });
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  Widget _buildCircle(AnimationController controller) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final scale = 0.5 + (controller.value * 0.5);
        // Start at 1.0 opacity when scale is 0.5 (progress 0)
        // Fade to 0.0 opacity when scale is 1.0 (progress 1)
        final opacity = 1.0 - controller.value;
        
        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                // ignore: deprecated_member_use
                color: AppColors.brandGreen.withOpacity(opacity),
                width: 4,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildCircle(_controller3),
          _buildCircle(_controller2),
          _buildCircle(_controller1),
          const Center(
            child: Icon(
              Icons.bluetooth_searching,
              color: AppColors.brandGreen,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}
