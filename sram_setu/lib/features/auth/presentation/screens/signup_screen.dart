import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neu_button.dart';
import '../../../../core/widgets/neu_container.dart';
import '../../../../core/widgets/neu_text_field.dart';
import '../controllers/auth_controller.dart';
import '../../domain/auth_state.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  final VoidCallback onNavigateToSignIn;

  const SignUpScreen({
    super.key,
    required this.onNavigateToSignIn,
  });

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreedToTerms = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    ref.read(authControllerProvider.notifier).signUp(
          fullName: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
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
                  const SizedBox(height: 10),

                  // Brand Icon & Badge
                  Center(
                    child: NeuContainer(
                      width: 80,
                      height: 80,
                      borderRadius: 24,
                      depthType: NeuDepthType.convex,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.handyman_rounded,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // App Name & Subtitle
                  const Center(
                    child: Text(
                      'SRAM SETU',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'श्रम सेतु • Customer Registration',
                      style: TextStyle(
                        color: AppColors.primary.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Sign up to book verified home service experts',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Error Message Banner (if any)
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
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Form Inputs in a tactile Neumorphic Card
                  NeuContainer(
                    padding: const EdgeInsets.all(22),
                    borderRadius: 24,
                    depthType: NeuDepthType.convex,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Full Name
                        NeuTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          hint: 'e.g. Aditya Mishra',
                          prefixIcon: Icons.person_outline_rounded,
                          textInputAction: TextInputAction.next,
                        ),

                        const SizedBox(height: 18),

                        // 2. Email
                        NeuTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          hint: 'name@example.com',
                          prefixIcon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),

                        const SizedBox(height: 18),

                        // 3. Password
                        NeuTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Min. 6 characters',
                          prefixIcon: Icons.lock_outline_rounded,
                          isPassword: true,
                          textInputAction: TextInputAction.next,
                        ),

                        const SizedBox(height: 18),

                        // 4. Confirm Password
                        NeuTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          hint: 'Re-enter your password',
                          prefixIcon: Icons.verified_user_outlined,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleSubmit(),
                        ),

                        const SizedBox(height: 20),

                        // Terms & Conditions Check
                        GestureDetector(
                          onTap: () {
                            setState(() => _agreedToTerms = !_agreedToTerms);
                          },
                          child: Row(
                            children: [
                              NeuContainer(
                                width: 22,
                                height: 22,
                                borderRadius: 6,
                                depthType: _agreedToTerms
                                    ? NeuDepthType.accent
                                    : NeuDepthType.sunken,
                                child: _agreedToTerms
                                    ? const Icon(Icons.check, size: 16, color: AppColors.textPrimary)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'I agree to transparent pricing terms & privacy policy',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 26),

                        // Sign Up Action Button
                        NeuButton(
                          text: 'Sign Up & Verify Email',
                          isLoading: isLoading,
                          icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.textPrimary, size: 20),
                          onPressed: _agreedToTerms ? _handleSubmit : null,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Already Have Account? Sign In
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onNavigateToSignIn,
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
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
