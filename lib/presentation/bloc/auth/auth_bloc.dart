import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/security/master_password_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthSetupPassword>(_onSetupPassword);
    on<AuthVerifyPassword>(_onVerifyPassword);
    on<AuthLock>(_onLock);
    on<AuthBiometricLogin>(_onBiometricLogin);
  }

  Future<void> _onCheckStatus(
      AuthCheckStatus event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final isSet = await MasterPasswordService.instance.isMasterPasswordSet();
      final canUseBiometric = await _checkBiometricAvailability();

      if (!isSet) {
        emit(state.copyWith(
          status: AuthStatus.noPasswordSet,
          biometricAvailable: canUseBiometric,
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.locked,
          biometricAvailable: canUseBiometric,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to check authentication status',
      ));
    }
  }

  Future<void> _onSetupPassword(
      AuthSetupPassword event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final success =
          await MasterPasswordService.instance.setupMasterPassword(event.password);

      if (success) {
        emit(state.copyWith(status: AuthStatus.authenticated));
      } else {
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Failed to set up password',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'An unexpected error occurred',
      ));
    }
  }

  Future<void> _onVerifyPassword(
      AuthVerifyPassword event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final status =
          await MasterPasswordService.instance.verifyMasterPassword(event.password);

      switch (status) {
        case MasterPasswordStatus.verified:
          emit(state.copyWith(status: AuthStatus.authenticated));
          break;
        case MasterPasswordStatus.notSet:
          emit(state.copyWith(status: AuthStatus.noPasswordSet));
          break;
        case MasterPasswordStatus.error:
          emit(state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Incorrect password',
          ));
          break;
        default:
          emit(state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Authentication failed',
          ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Authentication error',
      ));
    }
  }

  Future<void> _onLock(AuthLock event, Emitter<AuthState> emit) async {
    MasterPasswordService.instance.lock();
    emit(state.copyWith(
      status: AuthStatus.locked,
      errorMessage: null,
    ));
  }

  Future<void> _onBiometricLogin(
      AuthBiometricLogin event, Emitter<AuthState> emit) async {
    // A successful OS prompt does not recover the master password or the
    // encryption key. Do not grant app access until a protected key-unlock
    // flow exists.
    MasterPasswordService.instance.lock();
    emit(state.copyWith(
      status: AuthStatus.locked,
      biometricAvailable: false,
      errorMessage: 'Biometric unlock is unavailable; enter your master password',
    ));
  }

  Future<bool> _checkBiometricAvailability() async {
    // Biometrics cannot unlock EncryptionService's in-memory master key yet.
    return false;
  }
}
