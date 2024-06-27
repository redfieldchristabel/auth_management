import 'dart:async';

import 'package:auth_management/auth_management.dart';
import 'package:auth_management/models/base_user.dart';
import 'package:auth_management/models/user_auth_state.dart';
import 'package:auth_management/services/auth_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// A function type for redirecting the GoRouter to a different route.
typedef GoRouterRedirectFunction = FutureOr<String?> Function(
    BuildContext, GoRouterState);

/// An abstract base class for defining an authentication route service.
abstract class BaseAuthRouteService {
  /// The route location to navigate to after successful authentication.
  String get afterAuthRouteLocation;

  /// The route location then will navigate to [afterAuthRouteLocation].
  /// Currently only [SignInRoute] will redirect to [afterAuthRouteLocation]
  /// if user is exists, maybe you have extra screen then also perform and
  /// authentication and need to redirect to [afterAuthRouteLocation].
  ///
  /// example: is magic link feature, signup, etc.
  ///
  /// circumstances that you maybe familiar is after
  /// sign up user are auto login to the app without need
  /// to re-login again.
  List<String> get triggerAfterAuthRouteLocationRoutes => [];

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
  GoRouter routerConfig() {
    return GoRouter(
      refreshListenable: refreshListenable,
      routes: routes,
      redirect: authGateFuncGenerator(),
      errorBuilder: errorScreenBuilder,
    );
  }

  /// The test screen widget.
  /// put your screen here to bypass all the auth gate
  /// remove this override to use auth gate
  Widget? get testScreen => null;

  /// The list of test routes.
  ///
  /// [withoutAuthRoutes] is used to bypass the auth gate
  /// if you need to redirect to other page while using [testScreen],
  /// you need to include that route in this list
  List<String> get testRoutes => [];

  /// Gate for authorization redirect.
  /// Use this override to bypass the auth gate.
  /// Normally used for role checking
  ///
  /// Return a screen route location to redirect to those routes
  /// Return null to proceed with context route
  String? authorizationGate(BaseUser user) => null;

  /// Generates the authentication gate redirect function.
  GoRouterRedirectFunction authGateFuncGenerator() {
    return (BuildContext context, GoRouterState state) {
      if (kDebugMode) {
        print(
            "trigger auth gate redirect builder for path ${state.fullPath} => ${state.uri.toString()} ${DateTime.now().millisecondsSinceEpoch}");
      }
      final con = ProviderScope.containerOf(context);
      final BaseUser? user = UserAuthState.currentUser;

      if (kDebugMode) {
        print("current user from UserAuthState $user");
      }

      final bool userExists = user != null;

      // return test screen in any case
      if (testScreen != null) {
        if (testRoutes.any((element) => element == state.uri.toString())) {
          return null;
        }

        return TestRoute().location;
      }

      if (kDebugMode) {
        print(state.uri.toString());
      }

      final bool excludeScreenCheck = withoutAuthRoutes?.any((element) =>
              element == state.fullPath ||
              state.uri.toString().contains(element)) ??
          false;

      if (kDebugMode) {
        print('user from container ref ${con.read(userNotifierProvider)}');
      }

      if (!userExists && !excludeScreenCheck) {
        if (kDebugMode) {
          print('User is not authenticated');
        }
        return SignInRoute().location;
      }

      if ([SignInRoute().location, ...triggerAfterAuthRouteLocationRoutes].any(
        (element) => (state.fullPath ?? state.uri.toString()) == element,
      )) {
        return afterAuthRouteLocation;
      }

      // authorization gate
      if (user != null) {
        return authorizationGate(user);
      }

      return null;
    };
  }
}
