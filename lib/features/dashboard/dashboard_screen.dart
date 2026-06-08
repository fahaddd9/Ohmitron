import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/error_entry.dart';
import '../../core/widgets/error_list_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        children: [
          ErrorListTile(
            errorEntry: ErrorEntry(
              timestamp: DateTime.now().subtract(const Duration(hours: 2)),
              errorCode: 'E001',
              message: 'Cell overvoltage detected in bank 2.',
              severity: 'critical',
            ),
          ),
          ErrorListTile(
            errorEntry: ErrorEntry(
              timestamp: DateTime.now().subtract(const Duration(days: 1)),
              errorCode: 'E007',
              message: 'BMS communication timeout. Retrying connection.',
              severity: 'info',
            ),
          ),
        ],
      ),
    );
  }
}
