import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/data_source_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Providers for tracking global device setup state
class PendingSerialNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setSerial(String? value) => state = value;
}
final pendingSerialProvider = NotifierProvider<PendingSerialNotifier, String?>(PendingSerialNotifier.new);

class CurrentSerialNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setSerial(String? value) => state = value;
}
final currentSerialProvider = NotifierProvider<CurrentSerialNotifier, String?>(CurrentSerialNotifier.new);

class ConnectionTypeSeenNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void setSeen(bool value) => state = value;
}
final connectionTypeSeenProvider = NotifierProvider<ConnectionTypeSeenNotifier, bool>(ConnectionTypeSeenNotifier.new);

enum SerialValidationResult {
  goToAuth,
  goToProvisioning,
  goToConnectionType,
  goToDashboard,
  error,
}

class DeviceSetupState {
  final String serial;
  final String? errorMessage;
  final bool isLoading;

  const DeviceSetupState({
    this.serial = '',
    this.errorMessage,
    this.isLoading = false,
  });

  DeviceSetupState copyWith({
    String? serial,
    String? errorMessage,
    bool? isLoading,
    bool clearError = false,
  }) {
    return DeviceSetupState(
      serial: serial ?? this.serial,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get isValidFormat {
    final regex = RegExp(r'^[A-Z0-9]{8,12}$');
    return regex.hasMatch(serial);
  }
}

class DeviceSetupNotifier extends Notifier<DeviceSetupState> {
  @override
  DeviceSetupState build() => const DeviceSetupState();

  void updateSerial(String val) {
    state = state.copyWith(serial: val.toUpperCase(), clearError: true);
  }

  Future<SerialValidationResult> validateAndProceed() async {
    if (!state.isValidFormat) {
      state = state.copyWith(errorMessage: 'Serial number must be 8–12 letters and numbers only.');
      return SerialValidationResult.error;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    
    final user = ref.read(authProvider).value;
    
    if (user == null) {
      ref.read(pendingSerialProvider.notifier).setSerial(state.serial);
      state = state.copyWith(isLoading: false);
      return SerialValidationResult.goToAuth;
    }

    final dataSource = ref.read(batteryDataSourceProvider);
    
    try {
      final isValid = await dataSource.validateSerial(state.serial);
      if (!isValid) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Device not found. Make sure your battery is powered on and within 1 metre of your phone.'
        );
        return SerialValidationResult.error;
      }

      final deviceInfo = await dataSource.getDeviceInfo(state.serial);
      ref.read(currentSerialProvider.notifier).setSerial(state.serial);

      if (deviceInfo.ownerUid == null && deviceInfo.provisioned) {
         await dataSource.forceReprovision(state.serial);
         state = state.copyWith(isLoading: false);
         return SerialValidationResult.goToProvisioning;
      }

      if (deviceInfo.ownerUid != null && deviceInfo.ownerUid != user.uid) {
         state = state.copyWith(
           isLoading: false,
           errorMessage: 'This device is registered to another account. Contact support to transfer ownership.'
         );
         return SerialValidationResult.error;
      }

      if (deviceInfo.ownerUid == user.uid && !deviceInfo.provisioned) {
         state = state.copyWith(isLoading: false);
         return SerialValidationResult.goToProvisioning;
      }

      if (deviceInfo.ownerUid == user.uid && deviceInfo.provisioned) {
         final hasSeenConnectionType = ref.read(connectionTypeSeenProvider);
         state = state.copyWith(isLoading: false);
         if (!hasSeenConnectionType) {
            return SerialValidationResult.goToConnectionType;
         } else {
            return SerialValidationResult.goToDashboard;
         }
      }

    } catch (e) {
       state = state.copyWith(
         isLoading: false,
         errorMessage: 'Could not connect. Please check your internet connection and try again.'
       );
       return SerialValidationResult.error;
    }
    
    state = state.copyWith(isLoading: false);
    return SerialValidationResult.error;
  }
}

final deviceSetupProvider = NotifierProvider<DeviceSetupNotifier, DeviceSetupState>(DeviceSetupNotifier.new);
