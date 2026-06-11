import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:barcode_widget/barcode_widget.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/info_row.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../device_setup/presentation/providers/device_setup_provider.dart';
import 'providers/basic_info_provider.dart';

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.space16, AppSpacing.space24, AppSpacing.space16, AppSpacing.space8),
      child: Text(
        title,
        style: AppTextStyles.headlineSmall.copyWith(color: AppColors.black),
      ),
    );
  }
}

class BasicInfoScreen extends ConsumerStatefulWidget {
  const BasicInfoScreen({super.key});

  @override
  ConsumerState<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends ConsumerState<BasicInfoScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isEditingName = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSetNameTapped(String currentName) async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty || newName.length > 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name must be between 1 and 30 characters')),
      );
      return;
    }

    if (newName == currentName) {
      setState(() {
        _isEditingName = false;
      });
      return;
    }

    final success = await ref.read(basicInfoProvider.notifier).updateDeviceName(newName);
    if (success && mounted) {
      setState(() {
        _isEditingName = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device name updated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(basicInfoProvider);
    final serial = ref.watch(currentSerialProvider) ?? 'UNKNOWN';

    ref.listen<BasicInfoState>(basicInfoProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
        ref.read(basicInfoProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: BackButton(
          color: AppColors.black,
          onPressed: () => context.go('/dashboard'),
        ),
        title: Text('Basic Information', style: AppTextStyles.headlineLarge),
      ),
      body: SafeArea(
        child: state.isLoading && state.deviceInfo == null
            ? const LoadingIndicator.fullScreen()
            : state.deviceInfo == null
                ? Center(
                    child: AppErrorWidget(
                      title: 'Error Loading Data',
                      message: state.error ?? 'Unknown error occurred.',
                      onRetry: () => ref.refresh(basicInfoProvider),
                    ),
                  )
                : _buildBody(state, serial),
      ),
    );
  }

  Widget _buildBody(BasicInfoState state, String serial) {
    final info = state.deviceInfo!;
    
    // Initialize text controller when entering edit mode, or if it's empty
    if (!_isEditingName && _nameController.text.isEmpty) {
      _nameController.text = info.friendlyName;
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader('Device Name'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider, width: 1.5),
                borderRadius: BorderRadius.circular(16),
                color: AppColors.surface,
              ),
              padding: const EdgeInsets.all(AppSpacing.space16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Device Name', style: AppTextStyles.bodySmall.copyWith(color: AppColors.darkGrey)),
                        if (_isEditingName)
                          TextField(
                            controller: _nameController,
                            maxLength: 30,
                            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.black),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                              border: InputBorder.none,
                              counterText: '',
                            ),
                            autofocus: true,
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              info.friendlyName,
                              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.black),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space8),
                  if (_isEditingName)
                    SizedBox(
                      width: 60,
                      height: 40,
                      child: AppButton(
                        label: 'SET',
                        isLoading: state.isLoading,
                        onPressed: () => _onSetNameTapped(info.friendlyName),
                      ),
                    )
                  else
                    SizedBox(
                      width: 60,
                      height: 40,
                      child: AppButton(
                        label: 'EDIT',
                        variant: AppButtonVariant.secondary,
                        onPressed: () {
                          setState(() {
                            _isEditingName = true;
                            _nameController.text = info.friendlyName;
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.space24),
          const SectionHeader('Device Details'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider, width: 1.5),
                borderRadius: BorderRadius.circular(16),
                color: AppColors.surface,
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16, vertical: AppSpacing.space8),
              child: Column(
                children: [
                  InfoRow(label: 'Serial Number', value: serial),
                  const Divider(height: 1, color: AppColors.divider),
                  InfoRow(label: 'Device Model', value: info.deviceModel),
                  const Divider(height: 1, color: AppColors.divider),
                  InfoRow(label: 'Firmware Version', value: info.firmwareVersion),
                  const Divider(height: 1, color: AppColors.divider),
                  InfoRow(label: 'BMS Model', value: info.bmsModel),
                  const Divider(height: 1, color: AppColors.divider),
                  InfoRow(label: 'BMS ID', value: info.bmsId),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.space24),
          const SectionHeader('Barcode'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider, width: 1.5),
                borderRadius: BorderRadius.circular(16),
                color: AppColors.surface,
              ),
              padding: const EdgeInsets.all(AppSpacing.space20),
              child: Center(
                child: BarcodeWidget(
                  data: serial,
                  barcode: Barcode.code128(),
                  width: MediaQuery.of(context).size.width - 96,
                  height: 80,
                  drawText: true,
                  style: AppTextStyles.bodySmall,
                  errorBuilder: (context, error) => Center(child: Text(error)),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.space24),
          const SectionHeader('Connection'),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.space16, right: AppSpacing.space16, bottom: AppSpacing.space32),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider, width: 1.5),
                borderRadius: BorderRadius.circular(16),
                color: AppColors.surface,
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16, vertical: AppSpacing.space8),
              child: Column(
                children: [
                  const InfoRow(label: 'Connection Type', value: 'Wi-Fi (Cloud Mode)'),
                  const Divider(height: 1, color: AppColors.divider),
                  InfoRow(label: 'Connected Network', value: info.connectedSsid ?? 'Unknown'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
