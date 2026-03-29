import '../../../core/security/master_password_service.dart';

class VerifyMasterPassword {
  Future<MasterPasswordStatus> call(String password) async {
    return MasterPasswordService.instance.verifyMasterPassword(password);
  }
}
