import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/app_user.dart';
import '../../../../providers/data_source_provider.dart';

class AuthNotifier extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    final dataSource = ref.watch(batteryDataSourceProvider);
    return dataSource.getCurrentUser();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final dataSource = ref.read(batteryDataSourceProvider);
      await dataSource.login(email, password);
      final user = await dataSource.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createAccount(
    String name,
    String email,
    String password,
    DateTime dob,
  ) async {
    state = const AsyncValue.loading();
    try {
      final dataSource = ref.read(batteryDataSourceProvider);
      await dataSource.createAccount(name, email, password, dob);
      final user = await dataSource.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      final dataSource = ref.read(batteryDataSourceProvider);
      await dataSource.logout();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AppUser?>(() {
  return AuthNotifier();
});
