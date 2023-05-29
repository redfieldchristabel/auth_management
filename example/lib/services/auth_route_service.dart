import 'package:auth_management/auth_management.dart';
import 'package:example/router.dart';

class AuthRouteService extends BaseAuthRouteService {
  @override
  String get homeRouteLocation => HomeRoute().location;
}

final AuthRouteService authRouteService = AuthRouteService();
