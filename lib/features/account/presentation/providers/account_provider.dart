import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/data_source_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AccountNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Initial state is just empty since it only performs actions
  }

  Future<void> updateProfile(String name, DateTime dob) async {
    state = const AsyncValue.loading();
    try {
      final dataSource = ref.read(batteryDataSourceProvider);
      await dataSource.updateProfile(name, dob);
      
      // Refresh the auth state to get updated user info
      ref.invalidate(authProvider);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    state = const AsyncValue.loading();
    try {
      final dataSource = ref.read(batteryDataSourceProvider);
      await dataSource.changePassword(currentPassword, newPassword);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> unpairDevice(String uid, String serial) async {
    state = const AsyncValue.loading();
    try {
      final dataSource = ref.read(batteryDataSourceProvider);
      await dataSource.unpairDevice(uid, serial);
      
      // Refresh auth state as deviceSerial will be cleared
      ref.invalidate(authProvider);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      final dataSource = ref.read(batteryDataSourceProvider);
      await dataSource.logout();
      
      // Refresh auth state which will become null
      ref.invalidate(authProvider);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> deleteAccount(String password) async {
    state = const AsyncValue.loading();
    try {
      final dataSource = ref.read(batteryDataSourceProvider);
      await dataSource.deleteAccount(password);
      
      // Refresh auth state which will become null
      ref.invalidate(authProvider);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

final accountProvider = AsyncNotifierProvider<AccountNotifier, void>(() {
  return AccountNotifier();
});
