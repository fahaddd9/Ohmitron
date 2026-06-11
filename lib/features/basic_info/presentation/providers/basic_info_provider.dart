import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/device_info.dart';
import '../../../../providers/data_source_provider.dart';
import '../../../device_setup/presentation/providers/device_setup_provider.dart';

class BasicInfoState {
  final DeviceInfo? deviceInfo;
  final bool isLoading;
  final String? error;

  const BasicInfoState({
    this.deviceInfo,
    this.isLoading = false,
    this.error,
  });

  BasicInfoState copyWith({
    DeviceInfo? deviceInfo,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return BasicInfoState(
      deviceInfo: deviceInfo ?? this.deviceInfo,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class BasicInfoNotifier extends Notifier<BasicInfoState> {
  @override
  BasicInfoState build() {
    Future.microtask(_fetchDeviceInfo);
    return const BasicInfoState(isLoading: true);
  }

  Future<void> _fetchDeviceInfo() async {
    final serial = ref.read(currentSerialProvider);
    if (serial == null) {
      state = state.copyWith(isLoading: false, error: 'No device serial found.');
      return;
    }

    try {
      final dataSource = ref.read(batteryDataSourceProvider);
      final info = await dataSource.getDeviceInfo(serial);
      state = state.copyWith(deviceInfo: info, isLoading: false, clearError: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load device info.');
    }
  }

  Future<bool> updateDeviceName(String newName) async {
    final serial = ref.read(currentSerialProvider);
    if (serial == null || state.deviceInfo == null) return false;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final dataSource = ref.read(batteryDataSourceProvider);
      await dataSource.updateDeviceName(serial, newName);
      
      // Update in-memory state
      state = state.copyWith(
        deviceInfo: state.deviceInfo!.copyWith(friendlyName: newName),
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to update device name.');
      return false;
    }
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(clearError: true);
    }
  }
}

final basicInfoProvider = NotifierProvider<BasicInfoNotifier, BasicInfoState>(BasicInfoNotifier.new);
