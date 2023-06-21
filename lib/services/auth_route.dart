import 'package:auth_management/auth_management.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'auth_route.g.dart';

@TypedGoRoute<SignInRoute>(
  path: '/sign-in',
)
class SignInRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BaseAuthService.authService.routeService.signInScreen;
  }
}

@TypedGoRoute<SignUpRoute>(
  path: '/sign-up',
)
class SignUpRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BaseAuthService.authService.routeService.signInScreen;
  }
}

@TypedGoRoute<TestRoute>(path: "/test")
class TestRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BaseAuthService.authService.routeService.testScreen!;
  }
}
