import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../models/wifi_network.dart';
import 'providers/provisioning_provider.dart';
import 'widgets/animated_scan_widget.dart';

class ProvisioningScreen extends ConsumerStatefulWidget {
  const ProvisioningScreen({super.key});

  @override
  ConsumerState<ProvisioningScreen> createState() => _ProvisioningScreenState();
}

class _ProvisioningScreenState extends ConsumerState<ProvisioningScreen> {
  WifiNetwork? _selectedNetwork;
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(provisioningProvider);

    // Listen for error messages and show SnackBar
    ref.listen<ProvisioningData>(provisioningProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
        ref.read(provisioningProvider.notifier).clearError();
      }
      
      // Auto-navigate after complete
      if (next.step == ProvisioningState.complete && previous?.step != ProvisioningState.complete) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            // ignore: use_build_context_synchronously
            context.go('/connection-type');
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Device Setup', style: AppTextStyles.headlineLarge),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: _buildStateWidget(state.step, state),
        ),
      ),
    );
  }

  Widget _buildStateWidget(ProvisioningState step, ProvisioningData state) {
    switch (step) {
      case ProvisioningState.permissionCheck:
        return _buildPermissionCheck(key: const ValueKey('perm_check'));
      case ProvisioningState.permissionDenied:
        return _buildPermissionDenied(key: const ValueKey('perm_denied'));
      case ProvisioningState.scanning:
        return _buildScanning(key: const ValueKey('scanning'));
      case ProvisioningState.scanFailed:
        return _buildScanFailed(key: const ValueKey('scan_failed'));
      case ProvisioningState.networkSelection:
        return _buildNetworkSelection(state, key: const ValueKey('network_sel'));
      case ProvisioningState.sendingCredentials:
        return _buildSendingCredentials(key: const ValueKey('sending'));
      case ProvisioningState.complete:
        return _buildComplete(key: const ValueKey('complete'));
    }
  }

  Widget _buildPermissionCheck({Key? key}) {
    return Center(
      key: key,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LoadingIndicator.fullScreen(),
          const SizedBox(height: AppSpacing.space16),
          Text(
            'Checking permissions...',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDenied({Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bluetooth_disabled, size: 56, color: AppColors.errorRed),
          const SizedBox(height: AppSpacing.space24),
          Text(
            'Bluetooth Permission Required',
            style: AppTextStyles.headlineSmall.copyWith(color: AppColors.black),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space12),
          Text(
            'Please enable Bluetooth permission in your phone\'s Settings to set up your device.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkGrey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space32),
          AppButton(
            label: 'Open Settings',
            onPressed: () => openAppSettings(),
          ),
          const SizedBox(height: AppSpacing.space16),
          AppButton(
            label: 'Cancel Setup',
            variant: AppButtonVariant.secondary,
            onPressed: () => context.go('/serial-entry'),
          ),
        ],
      ),
    );
  }

  Widget _buildScanning({Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AnimatedScanWidget(),
          const SizedBox(height: AppSpacing.space32),
          Text(
            'Searching for your device...',
            style: AppTextStyles.headlineSmall.copyWith(color: AppColors.black),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space12),
          Text(
            'Make sure your battery is powered on and within 1 metre of your phone.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkGrey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.space48),
          TextButton(
            onPressed: () => context.go('/serial-entry'),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkGrey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanFailed({Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppErrorWidget(
            title: 'Device Not Found',
            message: 'Make sure your battery is powered on and within 1 metre of your phone, then try again.',
            onRetry: () => ref.read(provisioningProvider.notifier).retryScan(),
          ),
          const SizedBox(height: AppSpacing.space16),
          AppButton(
            label: 'Cancel',
            variant: AppButtonVariant.secondary,
            onPressed: () => context.go('/serial-entry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkSelection(ProvisioningData state, {Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16, vertical: AppSpacing.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Wi-Fi Network',
                style: AppTextStyles.headlineSmall.copyWith(color: AppColors.black),
              ),
              const SizedBox(height: AppSpacing.space8),
              Text(
                'Choose the Wi-Fi network you want your battery monitor to connect to.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkGrey),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space16),
        Expanded(
          child: ListView.separated(
            itemCount: state.networks.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.divider),
            itemBuilder: (context, index) {
              final network = state.networks[index];
              final isSelected = _selectedNetwork?.ssid == network.ssid;
              
              return ListTile(
                leading: Icon(
                  Icons.wifi,
                  color: isSelected ? AppColors.brandGreen : AppColors.darkGrey,
                  size: 24,
                ),
                title: Text(
                  network.ssid,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isSelected ? AppColors.brandGreen : AppColors.black,
                  ),
                ),
                trailing: const Icon(Icons.signal_wifi_4_bar, color: AppColors.darkGrey, size: 20),
                selected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedNetwork = network;
                    _passwordController.clear();
                  });
                },
              );
            },
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _selectedNetwork == null ? 0 : 200,
          curve: Curves.easeOutCubic,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: _selectedNetwork == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.all(AppSpacing.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Password for "${_selectedNetwork!.ssid}"',
                          style: AppTextStyles.labelMedium.copyWith(color: AppColors.darkGrey),
                        ),
                        const SizedBox(height: AppSpacing.space8),
                        AppTextField(
                          label: 'Wi-Fi Password',
                          controller: _passwordController,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (_) => _connect(),
                        ),
                        const SizedBox(height: AppSpacing.space16),
                        AppButton(
                          label: 'Connect Device',
                          isEnabled: _passwordController.text.isNotEmpty,
                          onPressed: _connect,
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _connect() {
    if (_selectedNetwork == null || _passwordController.text.isEmpty) return;
    ref.read(provisioningProvider.notifier).connectToNetwork(
      _selectedNetwork!.ssid,
      _passwordController.text,
    );
  }

  Widget _buildSendingCredentials({Key? key}) {
    return Center(
      key: key,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LoadingIndicator.fullScreen(),
          const SizedBox(height: AppSpacing.space24),
          Text(
            'Connecting your device...',
            style: AppTextStyles.headlineSmall.copyWith(color: AppColors.black),
          ),
          const SizedBox(height: AppSpacing.space8),
          Text(
            'This may take a few seconds.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildComplete({Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: const Icon(Icons.check_circle, size: 64, color: AppColors.brandGreen),
            ),
            const SizedBox(height: AppSpacing.space24),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 300),
              builder: (context, opacity, child) {
                return Opacity(
                  opacity: opacity,
                  child: child,
                );
              },
              child: Text(
                'Device Connected!',
                style: AppTextStyles.headlineMedium.copyWith(color: AppColors.black),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.space12),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              builder: (context, opacity, child) {
                // Ensure it fades in after the title (simple delay logic approximation)
                return Opacity(
                  opacity: opacity < 0.2 ? 0.0 : (opacity - 0.2) / 0.8,
                  child: child,
                );
              },
              child: Text(
                'Your battery monitor is now connected to ${_selectedNetwork?.ssid ?? 'your Wi-Fi'} and sending data.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkGrey),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
