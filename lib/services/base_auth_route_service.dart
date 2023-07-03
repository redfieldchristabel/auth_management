import 'dart:async';

import 'package:auth_management/auth_management.dart';
import 'package:auth_management/services/auth_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// A function type for redirecting the GoRouter to a different route.
typedef GoRouterRedirectFunction = FutureOr<String?> Function(
    BuildContext, GoRouterState);

/// An abstract base class for defining an authentication route service.
abstract class BaseAuthRouteService {
  /// The route location to navigate to after successful authentication.
  String get afterAuthRouteLocation;

  /// The list of authentication routes.
  List<RouteBase> get authRoutes => $appRoutes;

  /// The list of application routes.
  List<RouteBase> get appRoute;

  /// The combined list of application and authentication routes.
  List<RouteBase> get routes => appRoute..addAll(authRoutes);

  /// The sign-in screen widget.
  Widget get signInScreen;

  /// The sign-up screen widget.
  Widget get signUpScreen => signInScreen;

  /// The error screen widget builder.
  Widget Function(BuildContext context, GoRouterState state)?
      get errorScreenBuilder => null;

  /// The list of routes that don't require authentication.
  List<String>? get withoutAuthRoutes => [];

  /// The listenable object that triggers route refresh when changed.
  Listenable get refreshListenable =>
      BaseAuthService.authService.authListenable();

  /// Configures the GoRouter with the specified routes and settings.
  GoRouter routerConfig(WidgetRef ref) {
    return GoRouter(
      refreshListenable: refreshListenable,
      routes: routes,
      redirect: authGateFuncGenerator(ref),
      errorBuilder: errorScreenBuilder,
    );
  }

  Widget? get testScreen => null;

  /// Generates the authentication gate redirect function.
  GoRouterRedirectFunction authGateFuncGenerator(WidgetRef ref) {
    return (BuildContext context, GoRouterState state) {
      // return test screen in any case
      if (testScreen != null) {
        return TestRoute().location;
      }

      if (kDebugMode) {
        print(state.location);
      }

      final bool excludeScreenCheck =
          withoutAuthRoutes?.any((element) => element == state.location) ??
              false;

      if (ref.watch(userNotifierProvider) == null && !excludeScreenCheck) {
        if (kDebugMode) {
          print('User is not authenticated');
        }
        return SignInRoute().location;
      }

      if (state.location == SignInRoute().location) {
        return afterAuthRouteLocation;
      }
      return null;
    };
  }
}
