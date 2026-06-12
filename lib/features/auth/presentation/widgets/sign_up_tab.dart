import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/auth_provider.dart';
import '../providers/sign_up_form_provider.dart';

class SignUpTab extends ConsumerWidget {
  const SignUpTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(signUpFormProvider);
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    ref.listen(authProvider, (previous, next) {
      if (next is AsyncError && previous is! AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An account with this email already exists. Try logging in instead.'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      } else if (next is AsyncData && next.value != null && previous?.value == null) {
        // Success -> navigate to provisioning
        context.push('/provisioning');
      }
    });

    final dobFormatted = formState.dob != null ? DateFormat('dd MMM yyyy').format(formState.dob!) : '';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.space32),
            AppTextField(
              label: 'Full Name',
              keyboardType: TextInputType.name,
              maxLength: 60,
              textInputAction: TextInputAction.next,
              errorText: formState.nameError,
              onChanged: (val) => ref.read(signUpFormProvider.notifier).updateName(val),
            ),
            const SizedBox(height: AppSpacing.space16),
            AppTextField(
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              errorText: formState.emailError,
              onChanged: (val) => ref.read(signUpFormProvider.notifier).updateEmail(val),
            ),
            const SizedBox(height: AppSpacing.space16),
            AppTextField(
              label: 'Password',
              isPassword: true,
              helperText: 'Minimum 8 characters',
              textInputAction: TextInputAction.next,
              errorText: formState.passwordError,
              onChanged: (val) => ref.read(signUpFormProvider.notifier).updatePassword(val),
            ),
            const SizedBox(height: AppSpacing.space16),
            AppTextField(
              label: 'Confirm Password',
              isPassword: true,
              textInputAction: TextInputAction.done,
              errorText: formState.confirmPasswordError,
              onChanged: (val) => ref.read(signUpFormProvider.notifier).updateConfirmPassword(val),
            ),
            const SizedBox(height: AppSpacing.space16),
            GestureDetector(
              onTap: () async {
                final now = DateTime.now();
                final thirteenYearsAgo = DateTime(now.year - 13, now.month, now.day);
                final hundredYearsAgo = DateTime(now.year - 100, now.month, now.day);
                
                final picked = await showDatePicker(
                  context: context,
                  initialDate: thirteenYearsAgo,
                  firstDate: hundredYearsAgo,
                  lastDate: thirteenYearsAgo,
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppColors.brandGreen,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                
                if (picked != null) {
                  ref.read(signUpFormProvider.notifier).updateDob(picked);
                }
              },
              child: AbsorbPointer(
                child: AppTextField(
                  label: 'Date of Birth',
                  readOnly: true,
                  value: dobFormatted,
                  errorText: formState.dobError,
                  customSuffixIcon: const Icon(Icons.calendar_today, color: AppColors.darkGrey),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    activeColor: AppColors.brandGreen,
                    value: formState.agreeToTerms,
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(signUpFormProvider.notifier).toggleTerms(val);
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.space12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkGrey),
                      children: [
                        const TextSpan(text: 'I agree to the '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.brandGreen),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.brandGreen),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space24),
            AppButton(
              label: 'Create Account',
              isLoading: isLoading,
              isEnabled: formState.isFormValid,
              onPressed: () => _submit(ref),
            ),
            const SizedBox(height: AppSpacing.space32),
          ],
        ),
      ),
    );
  }

  void _submit(WidgetRef ref) {
    final notifier = ref.read(signUpFormProvider.notifier);
    if (notifier.validate()) {
      final state = ref.read(signUpFormProvider);
      ref.read(authProvider.notifier).createAccount(
        state.name,
        state.email,
        state.password,
        state.dob!,
      );
    }
  }
}
