import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginState {
  final String email;
  final String password;
  final String? emailError;
  final String? passwordError;

  const LoginState({
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
  });

  LoginState copyWith({
    String? email,
    String? password,
    String? emailError,
    String? passwordError,
    bool clearErrors = false,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: clearErrors ? null : (emailError ?? this.emailError),
      passwordError: clearErrors ? null : (passwordError ?? this.passwordError),
    );
  }
}

class LoginFormNotifier extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  void updateEmail(String email) => state = state.copyWith(email: email, clearErrors: true);
  void updatePassword(String password) => state = state.copyWith(password: password, clearErrors: true);
  
  bool validate() {
    String? emailErr;
    String? passErr;
    
    if (state.email.trim().isEmpty) {
      emailErr = 'Please enter an email address';
    } else if (!state.email.contains('@')) {
      emailErr = 'Please enter a valid email address';
    }
    
    if (state.password.isEmpty) {
      passErr = 'Please enter a password';
    }
    
    if (emailErr != null || passErr != null) {
      state = state.copyWith(emailError: emailErr, passwordError: passErr);
      return false;
    }
    return true;
  }
}

final loginFormProvider = NotifierProvider<LoginFormNotifier, LoginState>(LoginFormNotifier.new);
