/// Application configuration and environment credentials.
/// By default, [useMockAuth] is enabled so you can test all UI flows,
/// signups, and OTP verifications without needing Supabase keys immediately.
/// When you are ready, simply paste your Supabase URL and Anon Key below.
class AppConfig {
  AppConfig._();

  // Supabase Credentials (Provide these whenever you are ready)
  static const String supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  /// Whether to use interactive mock authentication instead of real Supabase.
  /// Automatically becomes false if real credentials are provided.
  static bool get useMockAuth =>
      supabaseUrl.contains('YOUR_PROJECT_ID') ||
      supabaseAnonKey.contains('YOUR_SUPABASE_ANON_KEY');

  /// Mock OTP sent for email verification during testing
  static const String mockVerificationOtp = '789123';
}
