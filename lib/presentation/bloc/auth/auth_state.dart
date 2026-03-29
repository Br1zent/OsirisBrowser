part of 'auth_bloc.dart';

enum AuthStatus {
  initial,
  loading,
  noPasswordSet,
  locked,
  authenticated,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String? errorMessage;
  final bool biometricAvailable;

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.biometricAvailable = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    bool? biometricAvailable,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      biometricAvailable: biometricAvailable ?? this.biometricAvailable,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, biometricAvailable];
}
