import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';
import '../../domain/auth_state.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthController(this._repository)
      : super(AuthState(isMockMode: _repository.isMock));

  /// Sign Up action with validation
  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final trimmedName = fullName.trim();
    final trimmedEmail = email.trim();

    if (trimmedName.isEmpty) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Please enter your full name.',
      );
      return false;
    }

    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Please provide a valid email address.',
      );
      return false;
    }

    if (password.length < 6) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Password must be at least 6 characters.',
      );
      return false;
    }

    if (password != confirmPassword) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Passwords do not match.',
      );
      return false;
    }

    state = state.copyWith(
      status: AuthStatus.authenticating,
      errorMessage: null,
    );

    try {
      await _repository.initiateSignUp(
        fullName: trimmedName,
        email: trimmedEmail,
        password: password,
      );

      state = state.copyWith(
        status: AuthStatus.otpPending,
        pendingEmail: trimmedEmail,
        pendingFullName: trimmedName,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception:', '').trim(),
      );
      return false;
    }
  }

  /// Verify Email OTP
  Future<bool> verifyOtp(String otp) async {
    final email = state.pendingEmail;
    final fullName = state.pendingFullName ?? 'Customer';

    if (email == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'No pending email verification found.',
      );
      return false;
    }

    if (otp.length != 6) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Please enter all 6 digits of the OTP.',
      );
      return false;
    }

    state = state.copyWith(
      status: AuthStatus.authenticating,
      errorMessage: null,
    );

    try {
      final user = await _repository.verifyEmailOtp(
        email: email,
        otp: otp,
        fullName: fullName,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        pendingEmail: null,
        pendingFullName: null,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.otpPending, // stay on OTP screen so user can retry
        errorMessage: e.toString().replaceAll('Exception:', '').trim(),
      );
      return false;
    }
  }

  /// Resend OTP
  Future<void> resendOtp() async {
    final email = state.pendingEmail;
    if (email == null) return;

    try {
      await _repository.resendOtp(email: email);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to resend code: $e',
      );
    }
  }

  /// Cancel OTP flow and return to Sign Up
  void cancelOtp() {
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      pendingEmail: null,
      pendingFullName: null,
      errorMessage: null,
    );
  }

  /// Customer Sign In
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.isEmpty) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Please fill in both email and password.',
      );
      return false;
    }

    state = state.copyWith(
      status: AuthStatus.authenticating,
      errorMessage: null,
    );

    try {
      final user = await _repository.signIn(
        email: trimmedEmail,
        password: password,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception:', '').trim(),
      );
      return false;
    }
  }

  /// Customer Sign Out
  Future<void> signOut() async {
    await _repository.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
