import '../../../core/security/master_password_service.dart';

class SetupMasterPassword {
  Future<bool> call(String password) async {
    return MasterPasswordService.instance.setupMasterPassword(password);
  }
}
