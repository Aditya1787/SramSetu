import 'package:flutter_test/flutter_test.dart';
import 'package:sram_setu/core/config/app_config.dart';
import 'package:sram_setu/features/auth/data/auth_repository.dart';
import 'package:sram_setu/features/auth/domain/auth_state.dart';
import 'package:sram_setu/features/auth/presentation/controllers/auth_controller.dart';

void main() {
  group('Customer Authentication Flow Tests', () {
    late AuthRepository repository;
    late AuthController controller;

    setUp(() {
      repository = AuthRepository();
      controller = AuthController(repository);
    });

    test('Initial state is unauthenticated and in mock mode', () {
      expect(controller.state.status, AuthStatus.unauthenticated);
      expect(controller.state.isMockMode, isTrue);
    });

    test('Sign Up fails when passwords do not match', () async {
      final success = await controller.signUp(
        fullName: 'Aditya Mishra',
        email: 'aditya@example.com',
        password: 'password123',
        confirmPassword: 'differentPassword',
      );

      expect(success, isFalse);
      expect(controller.state.status, AuthStatus.error);
      expect(controller.state.errorMessage, contains('Passwords do not match'));
    });

    test('Sign Up succeeds and transitions to otpPending state', () async {
      final success = await controller.signUp(
        fullName: 'Aditya Mishra',
        email: 'aditya@example.com',
        password: 'password123',
        confirmPassword: 'password123',
      );

      expect(success, isTrue);
      expect(controller.state.status, AuthStatus.otpPending);
      expect(controller.state.pendingEmail, 'aditya@example.com');
      expect(controller.state.pendingFullName, 'Aditya Mishra');
    });

    test('OTP verification fails with wrong OTP code', () async {
      // First sign up
      await controller.signUp(
        fullName: 'Aditya Mishra',
        email: 'aditya@example.com',
        password: 'password123',
        confirmPassword: 'password123',
      );

      final verified = await controller.verifyOtp('000000');
      expect(verified, isFalse);
      expect(controller.state.status, AuthStatus.otpPending);
      expect(controller.state.errorMessage, contains('Invalid OTP'));
    });

    test('OTP verification succeeds with valid OTP and transitions to authenticated', () async {
      // First sign up
      await controller.signUp(
        fullName: 'Aditya Mishra',
        email: 'aditya@example.com',
        password: 'password123',
        confirmPassword: 'password123',
      );

      // Verify with mock OTP
      final verified = await controller.verifyOtp(AppConfig.mockVerificationOtp);
      expect(verified, isTrue);
      expect(controller.state.status, AuthStatus.authenticated);
      expect(controller.state.user?.fullName, 'Aditya Mishra');
      expect(controller.state.user?.email, 'aditya@example.com');
      expect(controller.state.user?.role, 'customer');
    });
  });
}
