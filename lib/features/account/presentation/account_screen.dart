import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../device_setup/presentation/providers/connection_type_provider.dart';
import '../../notifications/presentation/providers/notifications_provider.dart';
import 'providers/account_provider.dart';

/// The Account screen with Profile, Security, Device, and Account sections.
/// Defined by UI_UX_BLUEPRINT.md Section 11.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.black, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('Account', style: AppTextStyles.headlineLarge),
      ),
      body: SafeArea(
        child: authState.when(
          loading: () => const Center(child: LoadingIndicator()),
          error: (e, _) => Center(
            child: Text('Error loading account', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.errorRed)),
          ),
          data: (user) {
            if (user == null) {
              // Should not happen if guards are in place, navigate away
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/serial-entry');
              });
              return const Center(child: LoadingIndicator());
            }
            return SingleChildScrollView(
              child: _AccountBody(user: user),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Body — splits widget tree for cleanliness
// ---------------------------------------------------------------------------

class _AccountBody extends ConsumerStatefulWidget {
  final dynamic user; // AppUser

  const _AccountBody({required this.user});

  @override
  ConsumerState<_AccountBody> createState() => _AccountBodyState();
}

class _AccountBodyState extends ConsumerState<_AccountBody> {
  late final TextEditingController _nameController;
  late DateTime _selectedDob;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _selectedDob = widget.user.dob;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} / ${date.month.toString().padLeft(2, '0')} / ${date.year}';
  }

  // ---------------------------------------------------------------------------
  // Profile
  // ---------------------------------------------------------------------------

  Future<void> _onPickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob,
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 13)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.brandGreen),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDob = picked);
    }
  }

  Future<void> _onSaveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(accountProvider.notifier).updateProfile(name, _selectedDob);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Change Password — Bottom Sheet
  // ---------------------------------------------------------------------------

  void _onChangePasswordTapped() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ChangePasswordSheet(),
    );
  }

  // ---------------------------------------------------------------------------
  // Remove Device
  // ---------------------------------------------------------------------------

  Future<void> _onRemoveDeviceTapped() async {
    final user = widget.user;
    if (user.deviceSerial == null) return;

    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Remove Device',
      body: 'Remove this device from your account? You can pair a new device afterwards. This will delete all notifications for this device.',
      confirmLabel: 'Remove',
      cancelLabel: 'Cancel',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      HapticFeedback.mediumImpact();
      try {
        await ref.read(accountProvider.notifier).unpairDevice(user.uid, user.deviceSerial!);
        // Cascade: clear related state
        ref.invalidate(notificationsProvider);
        ref.read(connectionTypeSeenProvider.notifier).state = false;
        if (mounted) context.go('/serial-entry');
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  Future<void> _onLogoutTapped() async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Log Out',
      body: 'Are you sure you want to log out?',
      confirmLabel: 'Log Out',
      cancelLabel: 'Cancel',
      isDestructive: false,
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(accountProvider.notifier).logout();
        ref.invalidate(notificationsProvider);
        ref.read(connectionTypeSeenProvider.notifier).state = false;
        if (mounted) context.go('/serial-entry');
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Delete Account
  // ---------------------------------------------------------------------------

  Future<void> _onDeleteAccountTapped() async {
    // Step 1 — first confirmation dialog
    final firstConfirm = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Account',
      body: 'Are you sure? This will permanently delete your account and cannot be undone.',
      confirmLabel: 'Yes, Delete My Account',
      cancelLabel: 'Cancel',
      isDestructive: true,
    );
    if (firstConfirm != true || !mounted) return;

    // Step 2 — password confirmation bottom sheet
    final password = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _DeletePasswordSheet(),
    );
    if (password == null || !mounted) return;

    HapticFeedback.mediumImpact();
    try {
      await ref.read(accountProvider.notifier).deleteAccount(password);
      ref.invalidate(notificationsProvider);
      ref.read(connectionTypeSeenProvider.notifier).state = false;
      if (mounted) context.go('/serial-entry');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Profile ───────────────────────────────────────────────────────────
        _SectionHeader(label: 'Profile'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider, width: 1.5),
            ),
            padding: const EdgeInsets.all(AppSpacing.space16),
            child: Column(
              children: [
                AppTextField(
                  label: 'Full Name',
                  controller: _nameController,
                  maxLength: 60,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.space16),
                GestureDetector(
                  onTap: _onPickDate,
                  child: AbsorbPointer(
                    child: AppTextField(
                      label: 'Date of Birth',
                      controller: TextEditingController(text: _formatDate(_selectedDob)),
                      customSuffixIcon: const Icon(Icons.calendar_today_outlined, color: AppColors.darkGrey),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.space16),
                AppTextField(
                  label: 'Email Address',
                  controller: TextEditingController(text: user.email),
                  readOnly: true,
                  helperText: 'Email cannot be changed in this version',
                ),
                const SizedBox(height: AppSpacing.space20),
                AppButton(
                  label: 'Save Changes',
                  onPressed: _isSaving ? null : _onSaveProfile,
                  isLoading: _isSaving,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.space24),

        // ── Security ──────────────────────────────────────────────────────────
        _SectionHeader(label: 'Security'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider, width: 1.5),
            ),
            child: ListTile(
              title: Text('Change Password', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.black)),
              trailing: const Icon(Icons.chevron_right, color: AppColors.disabled),
              onTap: _onChangePasswordTapped,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.space24),

        // ── Device ────────────────────────────────────────────────────────────
        _SectionHeader(label: 'Device'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider, width: 1.5),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.devices, color: AppColors.darkGrey),
                  title: Text('Paired Device', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.black)),
                  subtitle: Text(
                    user.deviceSerial ?? 'No device paired',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.darkGrey),
                  ),
                  trailing: user.deviceSerial != null
                      ? const AppBadge(label: 'Connected', variant: AppBadgeVariant.green)
                      : null,
                ),
                if (user.deviceSerial != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.space16,
                      right: AppSpacing.space16,
                      bottom: AppSpacing.space16,
                    ),
                    child: AppButton(
                      label: 'Remove Device',
                      variant: AppButtonVariant.secondary,
                      onPressed: _onRemoveDeviceTapped,
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.space24),

        // ── Account ───────────────────────────────────────────────────────────
        _SectionHeader(label: 'Account'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider, width: 1.5),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.darkGrey),
                  title: Text('Log Out', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.black)),
                  onTap: _onLogoutTapped,
                ),
                const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: AppColors.divider),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: AppColors.errorRed),
                  title: Text('Delete Account', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.errorRed)),
                  onTap: _onDeleteAccountTapped,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.space48),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section Header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.space16,
        bottom: AppSpacing.space12,
        top: AppSpacing.space4,
      ),
      child: Text(
        label,
        style: AppTextStyles.labelLarge.copyWith(color: AppColors.darkGrey),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Change Password Bottom Sheet
// ---------------------------------------------------------------------------

class _ChangePasswordSheet extends ConsumerStatefulWidget {
  const _ChangePasswordSheet();

  @override
  ConsumerState<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<_ChangePasswordSheet> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _currentPasswordError;
  String? _newPasswordError;
  String? _confirmPasswordError;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onUpdatePassword() async {
    setState(() {
      _currentPasswordError = null;
      _newPasswordError = null;
      _confirmPasswordError = null;
    });

    final current = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    bool hasError = false;
    if (current.isEmpty) {
      setState(() => _currentPasswordError = 'Required');
      hasError = true;
    }
    if (newPass.length < 8) {
      setState(() => _newPasswordError = 'Minimum 8 characters');
      hasError = true;
    }
    if (confirm != newPass) {
      setState(() => _confirmPasswordError = 'Passwords do not match');
      hasError = true;
    }
    if (hasError) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(accountProvider.notifier).changePassword(current, newPass);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully')),
        );
      }
    } catch (e) {
      setState(() => _currentPasswordError = 'Your current password is incorrect');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.space16,
        right: AppSpacing.space16,
        bottom: bottomInset + AppSpacing.space24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.space16),
          // Drag handle
          Center(
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Change Password', style: AppTextStyles.headlineMedium),
          ),
          const SizedBox(height: AppSpacing.space24),
          AppTextField(
            label: 'Current Password',
            controller: _currentPasswordController,
            isPassword: true,
            errorText: _currentPasswordError,
          ),
          const SizedBox(height: AppSpacing.space16),
          AppTextField(
            label: 'New Password',
            controller: _newPasswordController,
            isPassword: true,
            helperText: 'Minimum 8 characters',
            errorText: _newPasswordError,
          ),
          const SizedBox(height: AppSpacing.space16),
          AppTextField(
            label: 'Confirm New Password',
            controller: _confirmPasswordController,
            isPassword: true,
            errorText: _confirmPasswordError,
          ),
          const SizedBox(height: AppSpacing.space24),
          AppButton(
            label: 'Update Password',
            onPressed: _isLoading ? null : _onUpdatePassword,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Delete Account — Password Confirmation Bottom Sheet
// ---------------------------------------------------------------------------

class _DeletePasswordSheet extends StatefulWidget {
  const _DeletePasswordSheet();

  @override
  State<_DeletePasswordSheet> createState() => _DeletePasswordSheetState();
}

class _DeletePasswordSheetState extends State<_DeletePasswordSheet> {
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.space16,
        right: AppSpacing.space16,
        bottom: bottomInset + AppSpacing.space24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.space16),
          Center(
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Confirm Your Identity', style: AppTextStyles.headlineMedium),
          ),
          const SizedBox(height: AppSpacing.space8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Enter your password to confirm deletion.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkGrey),
            ),
          ),
          const SizedBox(height: AppSpacing.space24),
          AppTextField(
            label: 'Enter your password',
            controller: _passwordController,
            isPassword: true,
          ),
          const SizedBox(height: AppSpacing.space24),
          AppButton(
            label: 'Confirm Delete',
            variant: AppButtonVariant.destructive,
            onPressed: () => Navigator.of(context).pop(_passwordController.text.trim()),
          ),
        ],
      ),
    );
  }
}
