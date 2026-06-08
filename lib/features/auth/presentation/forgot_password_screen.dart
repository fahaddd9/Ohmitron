import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_button.dart';
import 'providers/forgot_password_provider.dart';

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(forgotPasswordProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: BackButton(
          color: AppColors.black,
          onPressed: () {
            ref.read(forgotPasswordProvider.notifier).resetState();
            context.pop();
          },
        ),
        title: Text('Reset Password', style: AppTextStyles.headlineLarge),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final isState2 = child.key == const ValueKey('state2');
            
            final slideAnimation = Tween<Offset>(
              begin: isState2 ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).animate(animation);

            return SlideTransition(
              position: slideAnimation,
              child: child,
            );
          },
          child: state.isConfirmation 
              ? const _ConfirmationState(key: ValueKey('state2'))
              : const _EnterEmailState(key: ValueKey('state1')),
        ),
      ),
    );
  }
}

class _EnterEmailState extends ConsumerWidget {
  const _EnterEmailState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(forgotPasswordProvider);
    final notifier = ref.read(forgotPasswordProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.space32),
          Text(
            'Enter your email address',
            style: AppTextStyles.headlineMedium.copyWith(color: AppColors.black),
          ),
          const SizedBox(height: AppSpacing.space8),
          Text(
            'We\'ll send a link to reset your password.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkGrey),
          ),
          const SizedBox(height: AppSpacing.space32),
          AppTextField(
            label: 'Email Address',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            errorText: state.emailError,
            onChanged: notifier.updateEmail,
            onSubmitted: (_) => notifier.sendResetLink(),
          ),
          const SizedBox(height: AppSpacing.space24),
          AppButton(
            label: 'Send Reset Link',
            isLoading: state.isSending,
            onPressed: notifier.sendResetLink,
          ),
        ],
      ),
    );
  }
}

class _ConfirmationState extends ConsumerWidget {
  const _ConfirmationState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(forgotPasswordProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.mark_email_read,
            size: 64,
            color: AppColors.brandGreen,
          ),
          const SizedBox(height: AppSpacing.space24),
          Text(
            'Check your inbox',
            style: AppTextStyles.headlineMedium.copyWith(color: AppColors.black),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space12),
          Text(
            'A password reset link has been sent to ${state.email}.\nFollow the link in the email to set a new password.\nCheck your spam folder if you don\'t see it.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkGrey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space48),
          AppButton(
            label: 'Back to Login',
            variant: AppButtonVariant.secondary,
            onPressed: () {
              ref.read(forgotPasswordProvider.notifier).resetState();
              context.pop();
            },
          ),
        ],
      ),
    );
  }
}
