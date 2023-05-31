import 'dart:async';

import 'package:auth_management/auth_management.dart';
import 'package:auth_management/services/auth_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

typedef GoROuterRedirectFunction = FutureOr<String?> Function(
    BuildContext, GoRouterState);

abstract class BaseAuthRouteService {
  String get afterAuthRouteLocation;

  List<RouteBase> get authRoutes => $appRoutes;

  List<RouteBase> get appRoute;

  List<RouteBase> get routes => appRoute..addAll(authRoutes);

  Widget get signInScreen;

  Widget get signUpScreen => signInScreen;

  Widget Function(BuildContext context, GoRouterState state)? get errorScreen =>
      null;

  List<String>? get withoutAuthRoutes => [];

  Listenable get refreshListenable =>
      BaseAuthService.authService.authListenable();

  GoRouter routerConfig(WidgetRef ref) {
    return GoRouter(
      refreshListenable: refreshListenable,
      routes: routes,
      redirect: authGateFuncGenerator(ref),
      errorBuilder: errorScreen,
    );
  }

  GoROuterRedirectFunction authGateFuncGenerator(WidgetRef ref) {
    return (BuildContext context, GoRouterState state) {
      final bool excludeScreenCheck =
          withoutAuthRoutes?.any((element) => element == state.location) ??
              false;

      if (ref.read(userNotifierProvider) == null && !excludeScreenCheck) {
        return SignInRoute().location;
      }

      if (state.location == SignInRoute().location) {
        return afterAuthRouteLocation;
      }
      return null;
    };
  }
}
