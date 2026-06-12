import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../../models/wifi_network.dart';
import '../../../../providers/data_source_provider.dart';

enum ProvisioningState {
  permissionCheck,
  permissionDenied,
  scanning,
  scanFailed,
  networkSelection,
  sendingCredentials,
  complete,
}

class ProvisioningData {
  final ProvisioningState step;
  final List<WifiNetwork> networks;
  final String? errorMessage;
  
  const ProvisioningData({
    this.step = ProvisioningState.permissionCheck,
    this.networks = const [],
    this.errorMessage,
  });

  ProvisioningData copyWith({
    ProvisioningState? step,
    List<WifiNetwork>? networks,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProvisioningData(
      step: step ?? this.step,
      networks: networks ?? this.networks,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ProvisioningNotifier extends Notifier<ProvisioningData> {
  @override
  ProvisioningData build() {
    // Start permission check automatically when provider is first read
    Future.microtask(() => checkPermissions());
    return const ProvisioningData();
  }

  Future<void> checkPermissions() async {
    state = state.copyWith(step: ProvisioningState.permissionCheck);
    
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // In a real app we'd check properly. For mock, we simulate success.
    state = state.copyWith(step: ProvisioningState.scanning);
    _startScan();
  }

  void _startScan() async {
    // Mock a 3 second scan delay
    await Future.delayed(const Duration(seconds: 3));
    
    state = state.copyWith(
      step: ProvisioningState.networkSelection,
      networks: const [
        WifiNetwork(ssid: 'HomeWiFi', signalStrength: -45),
        WifiNetwork(ssid: 'OfficeWiFi', signalStrength: -62),
        WifiNetwork(ssid: 'Ohmipower_Lab', signalStrength: -71),
        WifiNetwork(ssid: 'iPhone_Hotspot', signalStrength: -80),
      ],
    );
  }

  void retryScan() {
    state = state.copyWith(step: ProvisioningState.scanning);
    _startScan();
  }

  Future<bool> connectToNetwork(String ssid, String password) async {
    state = state.copyWith(step: ProvisioningState.sendingCredentials, clearError: true);
    
    final dataSource = ref.read(batteryDataSourceProvider);
    
    try {
      final success = await dataSource.provisionWiFi(ssid, password);
      
      if (success) {
        state = state.copyWith(step: ProvisioningState.complete);
        return true;
      } else {
        state = state.copyWith(
          step: ProvisioningState.networkSelection,
          errorMessage: 'Could not connect to that network. Please check the password and try again.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        step: ProvisioningState.networkSelection,
        errorMessage: 'Connection failed. Please try again.',
      );
      return false;
    }
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }
  
  void mockDenyPermissions() {
    state = state.copyWith(step: ProvisioningState.permissionDenied);
  }
  
  void mockFailScan() {
    state = state.copyWith(step: ProvisioningState.scanFailed);
  }
}

final provisioningProvider = NotifierProvider<ProvisioningNotifier, ProvisioningData>(ProvisioningNotifier.new);
