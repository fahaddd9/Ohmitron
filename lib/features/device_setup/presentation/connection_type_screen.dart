import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_badge.dart';
import 'providers/connection_type_provider.dart';

class ConnectionTypeScreen extends ConsumerStatefulWidget {
  const ConnectionTypeScreen({super.key});

  @override
  ConsumerState<ConnectionTypeScreen> createState() => _ConnectionTypeScreenState();
}

class _ConnectionTypeScreenState extends ConsumerState<ConnectionTypeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _card1Controller;
  late AnimationController _card2Controller;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _card1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _card2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Sequence the animations
    _fadeController.forward();
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _card1Controller.forward();
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _card2Controller.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _card1Controller.dispose();
    _card2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _fadeController,
          builder: (context, child) {
            return Opacity(
              opacity: Curves.easeInOut.transform(_fadeController.value),
              child: child,
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.space48,
                  left: AppSpacing.space16,
                  right: AppSpacing.space16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connection Method',
                      style: AppTextStyles.headlineLarge.copyWith(color: AppColors.black),
                    ),
                    const SizedBox(height: AppSpacing.space8),
                    Text(
                      'Your device is now configured to send data via Wi-Fi from anywhere.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkGrey),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
                child: Column(
                  children: [
                    _buildAnimatedCard(
                      controller: _card1Controller,
                      child: _buildActiveCard(),
                    ),
                    const SizedBox(height: AppSpacing.space16),
                    _buildAnimatedCard(
                      controller: _card2Controller,
                      child: _buildDisabledCard(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.space16,
                  right: AppSpacing.space16,
                  bottom: AppSpacing.space32,
                ),
                child: AppButton(
                  label: 'Continue',
                  onPressed: () {
                    ref.read(connectionTypeSeenProvider.notifier).markAsSeen();
                    context.go('/dashboard');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard({
    required AnimationController controller,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final value = Curves.easeOutCubic.transform(controller.value);
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildActiveCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.brandGreen, width: 2),
      ),
      padding: const EdgeInsets.all(AppSpacing.space20),
      child: Row(
        children: [
          const Icon(Icons.wifi, size: 32, color: AppColors.brandGreen),
          const SizedBox(width: AppSpacing.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wi-Fi (Cloud Mode)',
                  style: AppTextStyles.headlineSmall.copyWith(color: AppColors.black),
                ),
                Text(
                  'Monitor from anywhere via internet',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.darkGrey),
                ),
              ],
            ),
          ),
          const AppBadge(
            label: 'Active',
            variant: AppBadgeVariant.green,
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledCard() {
    return Opacity(
      opacity: 0.5,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider, width: 1.5),
        ),
        padding: const EdgeInsets.all(AppSpacing.space20),
        child: Row(
          children: [
            const Icon(Icons.bluetooth, size: 32, color: AppColors.disabled),
            const SizedBox(width: AppSpacing.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bluetooth (Direct Mode)',
                    style: AppTextStyles.headlineSmall.copyWith(color: AppColors.disabled),
                  ),
                  Text(
                    'Connect directly without internet',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.disabled),
                  ),
                ],
              ),
            ),
            const AppBadge(
              label: 'Coming Soon',
              variant: AppBadgeVariant.grey,
            ),
          ],
        ),
      ),
    );
  }
}
