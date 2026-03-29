part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckStatus extends AuthEvent {
  const AuthCheckStatus();
}

class AuthSetupPassword extends AuthEvent {
  final String password;
  const AuthSetupPassword(this.password);

  @override
  List<Object?> get props => [password];
}

class AuthVerifyPassword extends AuthEvent {
  final String password;
  const AuthVerifyPassword(this.password);

  @override
  List<Object?> get props => [password];
}

class AuthLock extends AuthEvent {
  const AuthLock();
}

class AuthBiometricLogin extends AuthEvent {
  const AuthBiometricLogin();
}
