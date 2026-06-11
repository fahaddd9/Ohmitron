import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_error_widget.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/error_list_tile.dart';
import '../../core/widgets/loading_indicator.dart';
import 'providers/error_report_provider.dart';

class ErrorReportScreen extends ConsumerWidget {
  const ErrorReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(errorReportProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: BackButton(
          color: AppColors.black,
          onPressed: () => context.go('/dashboard'),
        ),
        title: Text('Error Report', style: AppTextStyles.headlineLarge),
      ),
      body: SafeArea(
        child: _buildBody(context, ref, state),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ErrorReportState state) {
    if (state.isLoading && state.errors == null) {
      return const Center(
        child: LoadingIndicator.fullScreen(label: 'Loading error history...'),
      );
    }

    if (state.errorMessage != null && state.errors == null) {
      return Center(
        child: AppErrorWidget(
          title: 'Failed to load',
          message: state.errorMessage!,
          onRetry: () => ref.read(errorReportProvider.notifier).refreshErrors(),
        ),
      );
    }

    final errors = state.errors ?? [];

    if (errors.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.check_circle_outline,
        title: 'No Errors Recorded',
        subtitle: 'Your battery is running normally.',
      );
    }

    return RefreshIndicator(
      color: AppColors.brandGreen,
      onRefresh: () => ref.read(errorReportProvider.notifier).refreshErrors(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: errors.length,
        itemBuilder: (context, index) {
          final errorEntry = errors[index];
          return ErrorListTile(errorEntry: errorEntry);
        },
      ),
    );
  }
}
