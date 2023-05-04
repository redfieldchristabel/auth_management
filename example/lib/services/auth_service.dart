import 'package:auth_management/models/base_user.dart';
import 'package:auth_management/services/base_auth_service.dart';
import 'package:example/models/user.dart';
import 'package:isar/isar.dart';

class AuthService extends BaseAuthService<User> {
  Isar get isar => BaseAuthService.isar;

  @override
  Future<void> signIn() async {
    print("isar : ${isar.isOpen}");
    await isar.writeTxn(() async {
      await isar.users.put(User(id: '0', username: 'username', email: 'email'));
    });
  }

  @override
  IsarCollection<User> get usersIsar => isar.users;
}

final AuthService authService = AuthService();
