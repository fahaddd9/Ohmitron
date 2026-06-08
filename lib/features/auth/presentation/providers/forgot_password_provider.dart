import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/data_source_provider.dart';

class ForgotPasswordState {
  final String email;
  final String? emailError;
  final bool isSending;
  final bool isConfirmation;

  const ForgotPasswordState({
    this.email = '',
    this.emailError,
    this.isSending = false,
    this.isConfirmation = false,
  });

  ForgotPasswordState copyWith({
    String? email,
    String? emailError,
    bool? isSending,
    bool? isConfirmation,
    bool clearError = false,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      emailError: clearError ? null : (emailError ?? this.emailError),
      isSending: isSending ?? this.isSending,
      isConfirmation: isConfirmation ?? this.isConfirmation,
    );
  }
}

class ForgotPasswordNotifier extends Notifier<ForgotPasswordState> {
  @override
  ForgotPasswordState build() => const ForgotPasswordState();

  void updateEmail(String val) => state = state.copyWith(email: val, clearError: true);

  Future<void> sendResetLink() async {
    if (state.email.trim().isEmpty || !state.email.contains('@')) {
      state = state.copyWith(emailError: 'Please enter a valid email address');
      return;
    }

    state = state.copyWith(isSending: true);
    
    try {
      final dataSource = ref.read(batteryDataSourceProvider);
      await dataSource.sendPasswordResetEmail(state.email);
    } catch (e) {
      // Mock always succeeds. 
      // If error occurs, we still transition as per spec "ALWAYS transition to State 2".
    }

    state = state.copyWith(isSending: false, isConfirmation: true);
  }
  
  void resetState() {
    state = const ForgotPasswordState();
  }
}

final forgotPasswordProvider = NotifierProvider<ForgotPasswordNotifier, ForgotPasswordState>(ForgotPasswordNotifier.new);
