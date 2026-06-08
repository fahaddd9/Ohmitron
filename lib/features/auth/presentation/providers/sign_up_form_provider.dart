import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpState {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final DateTime? dob;
  final bool agreeToTerms;
  final String? nameError;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? dobError;

  const SignUpState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.dob,
    this.agreeToTerms = false,
    this.nameError,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.dobError,
  });

  SignUpState copyWith({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    DateTime? dob,
    bool? agreeToTerms,
    String? nameError,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
    String? dobError,
    bool clearErrors = false,
  }) {
    return SignUpState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      dob: dob ?? this.dob,
      agreeToTerms: agreeToTerms ?? this.agreeToTerms,
      nameError: clearErrors ? null : (nameError ?? this.nameError),
      emailError: clearErrors ? null : (emailError ?? this.emailError),
      passwordError: clearErrors ? null : (passwordError ?? this.passwordError),
      confirmPasswordError: clearErrors ? null : (confirmPasswordError ?? this.confirmPasswordError),
      dobError: clearErrors ? null : (dobError ?? this.dobError),
    );
  }

  bool get isFormValid =>
      name.trim().isNotEmpty &&
      email.contains('@') &&
      password.length >= 8 &&
      confirmPassword == password &&
      dob != null &&
      agreeToTerms;
}

class SignUpFormNotifier extends Notifier<SignUpState> {
  @override
  SignUpState build() => const SignUpState();

  void updateName(String val) => state = state.copyWith(name: val, clearErrors: true);
  void updateEmail(String val) => state = state.copyWith(email: val, clearErrors: true);
  void updatePassword(String val) => state = state.copyWith(password: val, clearErrors: true);
  void updateConfirmPassword(String val) => state = state.copyWith(confirmPassword: val, clearErrors: true);
  void updateDob(DateTime val) => state = state.copyWith(dob: val, clearErrors: true);
  void toggleTerms(bool val) => state = state.copyWith(agreeToTerms: val, clearErrors: true);

  bool validate() {
    String? nameErr, emailErr, passErr, confirmPassErr, dobErr;
    
    if (state.name.trim().isEmpty || state.name.length > 60) {
      nameErr = 'Please enter your name';
    }
    if (!state.email.contains('@')) {
      emailErr = 'Please enter a valid email address';
    }
    if (state.password.length < 8) {
      passErr = 'Password must be at least 8 characters';
    }
    if (state.confirmPassword != state.password) {
      confirmPassErr = 'Passwords do not match';
    }
    if (state.dob == null) {
      dobErr = 'You must be at least 13 years old to use this app';
    }

    if (nameErr != null || emailErr != null || passErr != null || confirmPassErr != null || dobErr != null) {
      state = state.copyWith(
        nameError: nameErr,
        emailError: emailErr,
        passwordError: passErr,
        confirmPasswordError: confirmPassErr,
        dobError: dobErr,
      );
      return false;
    }
    return true;
  }
}

final signUpFormProvider = NotifierProvider<SignUpFormNotifier, SignUpState>(SignUpFormNotifier.new);
