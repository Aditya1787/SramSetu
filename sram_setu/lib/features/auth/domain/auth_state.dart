enum AuthStatus {
  unauthenticated,
  authenticating,
  otpPending,
  authenticated,
  error,
}

class CustomerUser {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String role;
  final DateTime createdAt;

  const CustomerUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.role = 'customer',
    required this.createdAt,
  });
}

class AuthState {
  final AuthStatus status;
  final CustomerUser? user;
  final String? pendingEmail;
  final String? pendingFullName;
  final String? errorMessage;
  final bool isMockMode;

  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.user,
    this.pendingEmail,
    this.pendingFullName,
    this.errorMessage,
    this.isMockMode = true,
  });

  AuthState copyWith({
    AuthStatus? status,
    CustomerUser? user,
    String? pendingEmail,
    String? pendingFullName,
    String? errorMessage,
    bool? isMockMode,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      pendingEmail: pendingEmail ?? this.pendingEmail,
      pendingFullName: pendingFullName ?? this.pendingFullName,
      errorMessage: errorMessage,
      isMockMode: isMockMode ?? this.isMockMode,
    );
  }
}
