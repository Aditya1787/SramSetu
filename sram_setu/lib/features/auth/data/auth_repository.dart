import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/app_config.dart';
import '../domain/auth_state.dart';

class AuthRepository {
  final bool _isMock = AppConfig.useMockAuth;

  bool get isMock => _isMock;

  /// Initiate customer sign-up with Name, Email, Password
  Future<void> initiateSignUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    if (_isMock) {
      // Simulate network latency
      await Future.delayed(const Duration(milliseconds: 600));
      return;
    }

    try {
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': 'customer',
        },
      );
    } catch (e) {
      throw Exception('Supabase Sign-Up Failed: $e');
    }
  }

  /// Verify 6-digit Email OTP
  Future<CustomerUser> verifyEmailOtp({
    required String email,
    required String otp,
    required String fullName,
  }) async {
    if (_isMock) {
      await Future.delayed(const Duration(milliseconds: 700));
      // In mock mode, allow the predefined test OTP or any valid 6-digit code
      if (otp != AppConfig.mockVerificationOtp && otp != '123456') {
        throw Exception('Invalid OTP. Use test OTP: ${AppConfig.mockVerificationOtp} or 123456');
      }

      return CustomerUser(
        id: 'mock-cust-${DateTime.now().millisecondsSinceEpoch}',
        fullName: fullName.isNotEmpty ? fullName : 'Verified Customer',
        email: email,
        role: 'customer',
        createdAt: DateTime.now(),
      );
    }

    try {
      final response = await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.signup,
        token: otp,
        email: email,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('OTP verification failed: User session not found');
      }

      return CustomerUser(
        id: user.id,
        fullName: user.userMetadata?['full_name'] ?? fullName,
        email: user.email ?? email,
        phone: user.phone,
        role: user.userMetadata?['role'] ?? 'customer',
        createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
      );
    } catch (e) {
      throw Exception('OTP Verification Failed: $e');
    }
  }

  /// Resend Email OTP
  Future<void> resendOtp({required String email}) async {
    if (_isMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
    } catch (e) {
      throw Exception('Failed to resend OTP: $e');
    }
  }

  /// Sign In with Email and Password
  Future<CustomerUser> signIn({
    required String email,
    required String password,
  }) async {
    if (_isMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      return CustomerUser(
        id: 'mock-cust-login',
        fullName: 'Customer Demo',
        email: email,
        role: 'customer',
        createdAt: DateTime.now(),
      );
    }

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Sign in failed');
      }

      return CustomerUser(
        id: user.id,
        fullName: user.userMetadata?['full_name'] ?? 'Customer',
        email: user.email ?? email,
        phone: user.phone,
        role: user.userMetadata?['role'] ?? 'customer',
        createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
      );
    } catch (e) {
      throw Exception('Sign In Failed: $e');
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    if (_isMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      return;
    }

    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      throw Exception('Sign Out Failed: $e');
    }
  }
}
