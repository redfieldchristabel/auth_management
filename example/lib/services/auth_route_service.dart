import 'package:auth_management/auth_management.dart';
import 'package:example/main.dart';
import 'package:example/router.dart';
import 'package:example/screens/without_signin.dart';
import 'package:example/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthRouteService extends BaseAuthRouteService {
  @override
  String get afterAuthRouteLocation => HomeRoute().location;

  @override
  List<RouteBase> get appRoute => $appRoutes;

  @override
  Widget get signInScreen => const MyHomePage(
        title: 'sign in screen',
      );

  @override
  List<String>? get withoutAuthRoutes => [WithoutSignInRoute().location];

  @override
  Listenable get refreshListenable => authService.firebaseAuthListenable();
}

final AuthRouteService authRouteService = AuthRouteService();
