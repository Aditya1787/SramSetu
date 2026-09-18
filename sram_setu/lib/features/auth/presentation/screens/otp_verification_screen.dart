import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neu_button.dart';
import '../../../../core/widgets/neu_container.dart';
import '../../../../core/widgets/neu_otp_box.dart';
import '../controllers/auth_controller.dart';
import '../../domain/auth_state.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final GlobalKey<NeuOtpInputState> _otpKey = GlobalKey<NeuOtpInputState>();
  String _currentOtp = '';
  int _secondsRemaining = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleVerify() {
    if (_currentOtp.length == 6) {
      ref.read(authControllerProvider.notifier).verifyOtp(_currentOtp);
    }
  }

  void _handleResend() {
    if (_secondsRemaining == 0) {
      ref.read(authControllerProvider.notifier).resendOtp();
      _startCountdown();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final email = authState.pendingEmail ?? 'your email';
    final isLoading = authState.status == AuthStatus.authenticating;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Back button to change email
                  Align(
                    alignment: Alignment.centerLeft,
                    child: NeuContainer(
                      width: 44,
                      height: 44,
                      borderRadius: 14,
                      depthType: NeuDepthType.convex,
                      onTap: () {
                        ref.read(authControllerProvider.notifier).cancelOtp();
                      },
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Mail Icon Banner
                  Center(
                    child: NeuContainer(
                      width: 88,
                      height: 88,
                      borderRadius: 28,
                      depthType: NeuDepthType.accent,
                      child: Center(
                        child: Icon(
                          Icons.mark_email_unread_rounded,
                          size: 44,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title & Description
                  const Center(
                    child: Text(
                      'Verify Your Email',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        children: [
                          const TextSpan(text: 'Enter the 6-digit verification code sent to\n'),
                          TextSpan(
                            text: email,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Mock Mode Helper Pill
                  if (authState.isMockMode) ...[
                    NeuContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      borderRadius: 14,
                      depthType: NeuDepthType.sunken,
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.8),
                        width: 1,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Dev Mode: Supabase keys pending. Use test OTP: ${AppConfig.mockVerificationOtp}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _otpKey.currentState?.setOtp(AppConfig.mockVerificationOtp);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Auto Fill',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Error Banner
                  if (authState.errorMessage != null) ...[
                    NeuContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      borderRadius: 14,
                      depthType: NeuDepthType.sunken,
                      border: Border.all(color: AppColors.error, width: 1),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              authState.errorMessage!,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 6-Digit Neumorphic OTP Input Card
                  NeuContainer(
                    padding: const EdgeInsets.all(24),
                    borderRadius: 24,
                    depthType: NeuDepthType.convex,
                    child: Column(
                      children: [
                        NeuOtpInput(
                          key: _otpKey,
                          length: 6,
                          onChanged: (code) {
                            setState(() => _currentOtp = code);
                          },
                          onCompleted: (code) {
                            setState(() => _currentOtp = code);
                            _handleVerify();
                          },
                        ),
                        const SizedBox(height: 28),

                        // Verify Action Button
                        NeuButton(
                          text: 'Verify & Continue',
                          isLoading: isLoading,
                          icon: const Icon(Icons.check_circle_outline, color: AppColors.textPrimary, size: 20),
                          onPressed: _currentOtp.length == 6 ? _handleVerify : null,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Resend Code Timer & Button
                  Center(
                    child: _secondsRemaining > 0
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.timer_outlined, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Text(
                                'Resend code in ${_secondsRemaining}s',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          )
                        : GestureDetector(
                            onTap: _handleResend,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.refresh_rounded, size: 18, color: AppColors.primary),
                                SizedBox(width: 6),
                                Text(
                                  'Resend Verification Code',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
