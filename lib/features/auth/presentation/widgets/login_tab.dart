import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/auth_provider.dart';
import '../providers/login_form_provider.dart';

class LoginTab extends ConsumerWidget {
  const LoginTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(loginFormProvider);
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    ref.listen(authProvider, (previous, next) {
      if (next is AsyncError && previous is! AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incorrect email or password. Please try again.'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      } else if (next is AsyncData && next.value != null && previous?.value == null) {
        // Success login -> navigate to provisioning
        context.push('/provisioning');
      }
    });

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.space32),
            AppTextField(
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              errorText: formState.emailError,
              onChanged: (val) => ref.read(loginFormProvider.notifier).updateEmail(val),
            ),
            const SizedBox(height: AppSpacing.space16),
            AppTextField(
              label: 'Password',
              isPassword: true,
              textInputAction: TextInputAction.done,
              errorText: formState.passwordError,
              onChanged: (val) => ref.read(loginFormProvider.notifier).updatePassword(val),
              onSubmitted: (_) => _submit(ref),
            ),
            const SizedBox(height: AppSpacing.space8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  context.push('/forgot-password');
                },
                child: Text(
                  'Forgot Password?',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.brandGreen),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space24),
            AppButton(
              label: 'Log In',
              isLoading: isLoading,
              onPressed: () => _submit(ref),
            ),
            const SizedBox(height: AppSpacing.space16),
          ],
        ),
      ),
    );
  }

  void _submit(WidgetRef ref) {
    final notifier = ref.read(loginFormProvider.notifier);
    if (notifier.validate()) {
      final state = ref.read(loginFormProvider);
      ref.read(authProvider.notifier).login(state.email, state.password);
    }
  }
}
