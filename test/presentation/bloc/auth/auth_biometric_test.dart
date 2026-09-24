import 'package:flutter_test/flutter_test.dart';
import 'package:osiris_browser/presentation/bloc/auth/auth_bloc.dart';

void main() {
  test('biometric event cannot authenticate without unlocking the master key',
      () async {
    final bloc = AuthBloc();
    final nextState = expectLater(
      bloc.stream,
      emits(
        predicate<AuthState>((state) =>
            state.status == AuthStatus.locked &&
            !state.biometricAvailable &&
            state.errorMessage != null),
      ),
    );

    bloc.add(const AuthBiometricLogin());
    await nextState;

    expect(bloc.state.status, isNot(AuthStatus.authenticated));
    await bloc.close();
  });
}
