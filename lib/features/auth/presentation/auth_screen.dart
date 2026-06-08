import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

import 'widgets/login_tab.dart';
import 'widgets/sign_up_tab.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.space32,
                  left: AppSpacing.space16,
                  right: AppSpacing.space16,
                ),
                child: Column(
                  children: [
                    SvgPicture.asset(
                      'assets/images/ohmitron_logo.svg',
                      width: 56,
                      height: 56,
                    ),
                    const SizedBox(height: AppSpacing.space24),
                    TabBar(
                      indicatorColor: AppColors.brandGreen,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelStyle: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      labelColor: AppColors.brandGreen,
                      unselectedLabelColor: AppColors.darkGrey,
                      tabs: const [
                        Tab(text: 'Log In'),
                        Tab(text: 'Sign Up'),
                      ],
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    LoginTab(),
                    SignUpTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
