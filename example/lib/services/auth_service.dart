import 'package:auth_management/services/base_auth_service.dart';
import 'package:example/models/user.dart';
import 'package:isar/isar.dart';

class AuthService extends BaseAuthService {
  Isar get isar => BaseAuthService.isar;

  @override
  Future<void> signIn() async {
    print("isar : ${isar.isOpen}");
    await isar.writeTxn(() async {
      await isar.users.put(User(id: '0', username: 'username', email: 'email'));
    });
  }
}

final AuthService authService = AuthService();
