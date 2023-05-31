import 'package:auth_management/auth_management.dart';
import 'package:auth_management/services/base_auth_service.dart';
import 'package:auth_management/services/firebase_auth_service.dart';
import 'package:example/models/example_user.dart';
import 'package:example/services/auth_route_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isar/isar.dart';

class AuthService extends BaseAuthService<ExampleUser>
    with FirebaseAuthService<ExampleUser> {
  Isar get isar => BaseAuthService.isar;

  @override
  IsarCollection<ExampleUser> get usersIsar => isar.exampleUsers;

  @override
  BaseAuthRouteService get routeService => authRouteService;

  @override
  Future<ExampleUser?> userMorph(User? user) async {
    if (user == null) return null;
    return ExampleUser(
      id: user.uid,
      username: user.displayName ?? "No Username",
      email: user.email ?? "No Email",
    );
  }
}

final AuthService authService = AuthService();
