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

typedef GoRouterRedirectFunction = FutureOr<String?> Function(
    BuildContext, GoRouterState);

/// An abstract base class for defining authentication route services.

/// This abstract class provides a blueprint for implementing services that manage routes within your
/// application's authentication flow.

/// Subclasses of `BaseAuthRouteService` should implement the specific logic for determining which routes
/// require authentication, handling redirects when users are not authenticated, and potentially defining
/// custom logic for role-based authorization within your application.

/// This approach promotes code reusability and separation of concerns by isolating authentication-related
/// route management logic within dedicated service classes.
abstract class BaseAuthRouteService {
  String? overrideRoute;

  /// A temporary initial route location used for deep links or notifications.
  ///
  /// This variable holds a route location that takes priority over
  /// [afterAuthRouteLocation] but only for a single navigation cycle.
  /// It's typically used for scenarios where the app is opened via a deep link
  /// or notification, and you want to redirect the user to a specific location
  /// after successful authentication.
  ///
  /// This value is automatically cleared after it's been used for navigation,
  /// ensuring it doesn't interfere with subsequent navigation behavior.
  String? tempInitialRoute;

  String get _initialRoute => tempInitialRoute ?? afterAuthRouteLocation;

  /// The route location to navigate to after successful authentication.
  ///
  /// This property defines the default route where users will be directed
  /// after they successfully log in or sign up. It serves as the primary
  /// landing point after authentication is complete.
  ///
  /// You can customize this value to point to the main application screen
  /// or any other location within your app's route hierarchy.
  String get afterAuthRouteLocation;

  /// The list of routes that trigger navigation to [afterAuthRouteLocation] after successful authentication.

  /// This property specifies a list of route locations (strings) within your application.
  /// Upon successful user authentication (login or signup), if the user lands on any of these routes,
  /// they will be automatically redirected to the `afterAuthRouteLocation`.

  /// This behavior is useful for scenarios where certain routes (e.g., signup screen) act as a stepping stone
  /// leading to the main application area represented by `afterAuthRouteLocation`.

  /// Here are some examples:
  ///   - A signup screen that automatically redirects users to the main app after successful registration.
  ///   - A magic link confirmation's screen that redirects users to the main app after successful authentication via the link.

  /// If this list is empty (the default behavior), users will only be redirected to `afterAuthRouteLocation`
  /// if they land on the sign-in route [SignInRoute] after successful authentication.
  List<String> get triggerAfterAuthRouteLocationRoutes => [];

  /// The list of authentication routes managed by this service.

  /// This property provides a collection of `RouteBase` objects representing all the default authentication
  /// routes automatically generated by this service. These routes typically include:
  ///   - Login screen (location retrieved from `$signInRoute`)
  ///   - Signup screen (location retrieved from `$signUpRoute`)
  ///   - Optional test screen (location retrieved from `$testRoute`) (for bypassing authentication during development)

  /// **Important Note:** Modifying this property directly is generally discouraged unless you have a thorough
  /// understanding of the authentication flow and its implications. It's recommended to leverage the
  /// provided configuration options (such as overriding `signInRoute`, `signUpRoute`, or `testRoute`)
  /// to customize the individual route locations. Altering `authRoutes` directly might lead to unexpected
  /// behavior in the authentication process.

  /// If you need more granular control over specific authentication routes, consider overriding the relevant
  /// properties (`signInRoute`, `signUpRoute`, or `testRoute`) instead.
  List<RouteBase> get authRoutes => $appRoutes;

  /// This property holds a collection of application routes.
  ///
  /// This list allows for the definition of custom application routes that are not directly related to the
  /// authentication process. These routes represent different screens or functionalities within an application.
  ///
  /// To specify the application's navigation structure, add your own `RouteBase` objects to this list.
  ///
  /// The `appRoutes` list is combined with the `authRoutes` (automatically generated authentication routes)
  /// to form the complete set of routes used by the `routerConfig` method. This combined list ensures seamless
  /// navigation between application screens and authentication flows.
  ///
  /// It's important to note that routes defined here typically do not require authentication by default. If specific
  /// routes within an application require authentication, additional logic might be necessary to handle
  /// authorization checks and redirects using the provided authentication features.
  List<RouteBase> get appRoute;

  /// The combined list of all application and authentication routes.
  ///
  /// This property provides a read-only view of the combined list of routes used by the `routerConfig` method.
  /// It's automatically generated by merging the `appRoutes` (custom application routes) with the `authRoutes`
  /// (automatically generated authentication routes). This combined list ensures seamless navigation between
  /// application screens and authentication flows.
  ///
  /// **Important Note:** Modifying this property directly is generally discouraged. This list is intended to be
  /// read-only and reflects the combined routing configuration. If you need to make changes to routes,
  /// consider modifying either the `appRoutes` or `authRoutes` properties individually. Altering
  /// `routes` directly might lead to unexpected behavior in the routing mechanism.
  List<RouteBase> get routes => appRoute..addAll(authRoutes);

  /// The widget representing the sign-in screen.
  ///
  /// This property provides access to the widget that renders the sign-in screen within your application.
  /// It's likely constructed and configured elsewhere in your codebase (implementation detail).
  ///
  /// The sign-in screen is a crucial component of the authentication flow. It typically allows users to enter
  /// their credentials (e.g., email and password) and attempt to log in to the application.
  ///
  /// You can potentially customize the sign-in screen widget by overriding this property with your own
  /// implementation. However, it's recommended to leverage the provided configuration options within the
  Widget get signInScreen;

  /// The widget representing the sign-up screen.
  ///
  /// This property provides access to the widget that renders the sign-up screen within your application.
  /// By default, it inherits the value from `signInScreen`. This means users will be directed to the same
  /// screen for both sign-in and sign-up unless you explicitly override this property.
  ///
  /// You can customize this property to point to a separate widget specifically designed for the sign-up process.
  /// This separate widget might offer additional fields for user information collection during account creation.
  Widget get signUpScreen => signInScreen;

  /// Optional error screen builder function.
  ///
  /// This property allows you to specify a custom builder function that defines the widget to be displayed
  /// when an error occurs during navigation within the authentication flow. The function takes two arguments:
  ///   - `BuildContext context`: The build context of the current widget tree.
  ///   - `GoRouterState state`: The current state object of the GoRouter navigation library.
  ///
  /// By default, this property is `null`, and the GoRouter library will handle displaying a generic error screen.
  ///
  /// You can use this property to customize the error screen displayed during authentication flow errors.
  /// This might be useful for providing specific error messages or UI elements relevant to your authentication process.
  Widget Function(BuildContext context, GoRouterState state)?
      get errorScreenBuilder => null;

  /// List of route locations (strings) that don't require authentication.
  ///
  /// This property holds a collection of route locations (typically strings) within your application that can be
  /// accessed by users without needing to be authenticated. These routes represent publicly accessible areas
  /// of your app that don't contain sensitive information.
  ///
  /// By default, this property is an empty list (`[]`), meaning most routes will require authentication.
  /// You can populate this list with specific route paths to grant access without requiring users to log in.
  ///
  /// It's important to exercise caution when adding routes to this list. Only include routes that don't expose
  /// sensitive information or functionality within your application.
  List<String>? get withoutAuthRoutes => [];

  /// The listenable object used by `GoRouter` for route refreshes.
  ///
  /// This property provides a listenable object that is internally used by the [GoRouter] library to trigger
  /// route refreshes automatically. When the authentication state changes (e.g., user logs in or logs out),
  /// [GoRouter] will detect these changes through this listenable and update the displayed routes accordingly.
  ///
  /// This will be included in [GoRouter.refreshListenable].
  Listenable get refreshListenable =>
      BaseAuthService.authService.authListenable();

  /// Optional test screen widget for bypassing authentication.
  ///
  /// This property allows you to define a widget that can be used to bypass the authentication flow for
  /// testing purposes. When set, this widget will be displayed instead of enforcing authentication checks.
  ///
  /// This property should primarily be used during development and testing to directly access screens
  /// that would normally require authentication. **It's important to remove this override before deploying
  /// your application to production, as it bypasses essential security measures.**
  Widget? get testScreen => null;

  /// List of test routes that bypass authentication (when [testScreen] is used).
  ///
  /// This property provides a collection of route locations (typically strings) that can be accessed while
  /// bypassing the authentication flow when the [testScreen] property is set. These routes should only be used
  /// for development and testing purposes.
  ///
  /// If you need to access additional routes from `testScreen`, you must include their locations (paths) within
  /// this list. Routes defined in the [withoutAuthRoutes] property are automatically accessible from `testScreen`.
  List<String> get testRoutes => [];

  /// Optional initial gate for initial redirection.
  ///TODO: add documentation
  String? initialGate() => null;

  /// Optional authorization gate for role-based redirection.
  ///
  /// This property allows you to define custom logic for redirecting users based on their roles after
  /// successful authentication. By default, users will be directed to the route they were originally
  /// attempting to access (the context route).
  ///
  /// This function takes a [BaseUser] object as input, containing information about the authenticated user.
  /// You can use this information to perform role checks and potentially redirect the user to a different
  /// route location (screen) based on their authorization level.
  ///
  /// Returning `null` from this function indicates that the default behavior (proceeding with the context route)
  /// should be used.
  ///
  /// **Important:** This functionality is intended for role-based authorization within your application.
  /// Bypassing the auth gate entirely should be done through the [testScreen] property, not through this function.
  String? authorizationGate(BaseUser user) => null;

  /// Generates a redirect function for `GoRouter` based on authentication state and authorization checks.
  ///
  /// This function creates a closure that serves as a `GoRouterRedirectFunction`. This function
  /// is responsible for determining whether a user should be redirected based on the following factors:
  ///
  /// * **Authentication State:** If the user is not authenticated and the route requires authentication,
  /// they will be redirected to the login route (defined by `SignInRoute`).
  /// * **Excluded Routes:** Certain routes might not require authentication and are defined in the `withoutAuthRoutes` list.
  ///Users will be allowed to access these routes without being logged in.
  ///* **Test Screen:** If the `testScreen` property is set (for testing purposes), it bypasses authentication checks
  ///and potentially redirects to a specific test route location based on the `testRoutes` list.
  ///* **Trigger After Auth Routes:** A specific set of routes might require redirection even after successful
  ///authentication. If the user is authenticated and the current route is one of these "trigger after auth" routes
  ///(defined elsewhere in your code), they will be redirected to a previously stored initial route
  ///using [_initialRoute].
  ///* **Authorization Gate (Optional):** If the `authorizationGate` property is defined, it allows for
  ///custom logic to be applied for redirecting users based on their roles after successful authentication.
  ///
  /// This function leverages `BuildContext` and `GoRouterState` objects to access information about the
  /// current context and navigation state. It also retrieves the current authenticated user (`BaseUser`)
  /// from `UserAuthState`.
  GoRouterRedirectFunction authGateFuncGenerator() {
    return (BuildContext context, GoRouterState state) {
      if (kDebugMode) {
        print(
            "trigger auth gate redirect builder for path ${state.fullPath} => ${state.uri.toString()}, tempInitial $tempInitialRoute ${DateTime.now().millisecondsSinceEpoch}");
      }

      if (overrideRoute != null) {
        final overrideInitialRoute = overrideRoute;
        if (kDebugMode) {
          print("redirecting to override route $overrideRoute");
        }
        overrideRoute = null;
        return overrideInitialRoute;
      }

      final con = ProviderScope.containerOf(context);
      final BaseUser? user = UserAuthState.currentUser;

      final initialGateRoute = initialGate();

      if (initialGateRoute != null) {
        if (kDebugMode) {
          print("redirecting to initial gate route $initialGateRoute");
        }
        return initialGateRoute;
      }

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
          print(
              'User is not authenticated and route ${state.fullPath} is not excluded');
          print('redirecting to ${SignInRoute().location}');
        }
        if (state.fullPath != SignInRoute().location) {
          tempInitialRoute = state.fullPath;
        }
        return SignInRoute().location;
      }

      if ([SignInRoute().location, ...triggerAfterAuthRouteLocationRoutes].any(
            (element) => (state.fullPath ?? state.uri.toString()) == element,
          ) &&
          userExists) {
        if (kDebugMode) {
          print(
              'User is authenticated and route ${state.fullPath} is one of trigger after auth route');
          print('redirecting to $_initialRoute');
        }
        final x = _initialRoute;
        tempInitialRoute = null;
        return x;
      }

      // authorization gate
      if (user != null) {
        return authorizationGate(user);
      }

      return null;
    };
  }

  /// Configures the GoRouter with the specified routes and settings.
  ///
  /// Returns a configured GoRouter instance that manages routing within the application.
  GoRouter routerConfig() {
    return GoRouter(
      refreshListenable: refreshListenable,
      routes: routes,
      redirect: authGateFuncGenerator(),
      errorBuilder: errorScreenBuilder,
    );
  }
}
