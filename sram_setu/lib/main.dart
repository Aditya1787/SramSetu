import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/app_config.dart';
import 'core/theme/neu_theme.dart';
import 'features/auth/domain/auth_state.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/screens/otp_verification_screen.dart';
import 'features/auth/presentation/screens/signin_screen.dart';
import 'features/auth/presentation/screens/signup_screen.dart';
import 'features/home/presentation/screens/customer_home_preview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase only if real credentials have been supplied
  if (!AppConfig.useMockAuth) {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: AppConfig.supabaseAnonKey,
      );
    } catch (e) {
      debugPrint('Supabase initialization deferred: $e');
    }
  }

  runApp(
    const ProviderScope(
      child: SramSetuApp(),
    ),
  );
}

class SramSetuApp extends StatelessWidget {
  const SramSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SRAM SETU — श्रम सेतु',
      debugShowCheckedModeBanner: false,
      theme: NeuTheme.darkTheme,
      home: const AuthFlowRouter(),
    );
  }
}

class AuthFlowRouter extends ConsumerStatefulWidget {
  const AuthFlowRouter({super.key});

  @override
  ConsumerState<AuthFlowRouter> createState() => _AuthFlowRouterState();
}

class _AuthFlowRouterState extends ConsumerState<AuthFlowRouter> {
  bool _isShowingSignIn = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    // 1. If authenticated, route to Customer Home Preview
    if (authState.status == AuthStatus.authenticated) {
      return const CustomerHomePreview();
    }

    // 2. If OTP verification is pending, show OTP Screen
    if (authState.status == AuthStatus.otpPending) {
      return const OtpVerificationScreen();
    }

    // 3. Otherwise show Sign In or Sign Up based on toggle
    if (_isShowingSignIn) {
      return SignInScreen(
        onNavigateToSignUp: () {
          setState(() => _isShowingSignIn = false);
        },
      );
    }

    return SignUpScreen(
      onNavigateToSignIn: () {
        setState(() => _isShowingSignIn = true);
      },
    );
  }
}
