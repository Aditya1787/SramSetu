import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/neu_button.dart';
import '../../../../core/widgets/neu_container.dart';
import '../../../../core/widgets/neu_text_field.dart';
import '../controllers/auth_controller.dart';
import '../../domain/auth_state.dart';

class SignInScreen extends ConsumerStatefulWidget {
  final VoidCallback onNavigateToSignUp;

  const SignInScreen({
    super.key,
    required this.onNavigateToSignUp,
  });

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    ref.read(authControllerProvider.notifier).signIn(
          email: _emailController.text,
          password: _passwordController.text,
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
                  const SizedBox(height: 20),

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
                      'Customer Sign In',
                      style: TextStyle(
                        color: AppColors.primary.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

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
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Form Card
                  NeuContainer(
                    padding: const EdgeInsets.all(22),
                    borderRadius: 24,
                    depthType: NeuDepthType.convex,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        NeuTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          hint: 'name@example.com',
                          prefixIcon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),

                        const SizedBox(height: 18),

                        NeuTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Enter your password',
                          prefixIcon: Icons.lock_outline_rounded,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleSignIn(),
                        ),

                        const SizedBox(height: 24),

                        NeuButton(
                          text: 'Sign In',
                          isLoading: isLoading,
                          icon: const Icon(Icons.login_rounded, color: AppColors.textPrimary, size: 20),
                          onPressed: _handleSignIn,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Switch to Sign Up
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onNavigateToSignUp,
                        child: const Text(
                          'Register Now',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
