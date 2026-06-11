import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/error_entry.dart';
import '../../../../providers/data_source_provider.dart';
import '../../device_setup/presentation/providers/device_setup_provider.dart';

class ErrorReportState {
  final List<ErrorEntry>? errors;
  final bool isLoading;
  final String? errorMessage;

  const ErrorReportState({
    this.errors,
    this.isLoading = false,
    this.errorMessage,
  });

  ErrorReportState copyWith({
    List<ErrorEntry>? errors,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ErrorReportState(
      errors: errors ?? this.errors,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ErrorReportNotifier extends Notifier<ErrorReportState> {
  @override
  ErrorReportState build() {
    Future.microtask(refreshErrors);
    return const ErrorReportState(isLoading: true);
  }

  Future<void> refreshErrors() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    final serial = 'OHM00123456'; // ref.read(currentSerialProvider);
    if (serial == null) {
      state = state.copyWith(isLoading: false, errorMessage: 'No device connected.');
      return;
    }

    try {
      final dataSource = ref.read(batteryDataSourceProvider);
      final fetchedErrors = await dataSource.getErrors(serial);
      state = state.copyWith(errors: fetchedErrors, isLoading: false, clearError: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to load error report.');
    }
  }
}

final errorReportProvider = NotifierProvider<ErrorReportNotifier, ErrorReportState>(ErrorReportNotifier.new);
