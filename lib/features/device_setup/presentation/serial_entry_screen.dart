import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_button.dart';
import 'providers/device_setup_provider.dart';

class AlphanumericFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final filtered = newValue.text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    return newValue.copyWith(text: filtered.toUpperCase());
  }
}

class SerialEntryScreen extends ConsumerWidget {
  const SerialEntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deviceSetupProvider);
    final notifier = ref.read(deviceSetupProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.space48),
              child: Column(
                children: [
                  SvgPicture.asset(
                    'assets/images/ohmitron_logo.svg',
                    width: 64,
                    height: 64,
                  ),
                  const SizedBox(height: AppSpacing.space32),
                  Text(
                    'Enter Serial Number',
                    style: AppTextStyles.headlineLarge.copyWith(color: AppColors.black),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.space8),
                  Text(
                    'Found on the label on your battery unit',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkGrey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
              child: Column(
                children: [
                  AppTextField(
                    label: 'Serial Number',
                    hintText: 'e.g. OHM00123456',
                    keyboardType: TextInputType.text,
                    maxLength: 12,
                    errorText: state.errorMessage,
                    onChanged: notifier.updateSerial,
                    onSubmitted: (_) => _handleContinue(context, ref),
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
                isEnabled: state.isValidFormat,
                isLoading: state.isLoading,
                onPressed: () => _handleContinue(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleContinue(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(deviceSetupProvider.notifier);
    final result = await notifier.validateAndProceed();

    if (!context.mounted) return;

    switch (result) {
      case SerialValidationResult.goToAuth:
        context.go('/auth');
        break;
      case SerialValidationResult.goToProvisioning:
        context.go('/provisioning');
        break;
      case SerialValidationResult.goToConnectionType:
        context.go('/connection-type');
        break;
      case SerialValidationResult.goToDashboard:
        context.go('/dashboard');
        break;
      case SerialValidationResult.error:
        // Error is already displayed in the UI via state.errorMessage
        break;
    }
  }
}
