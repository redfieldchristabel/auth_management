import 'package:auth_management/widgets/sign_in_sign_up/sign_in_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'sign_in_sign_up_screen_handler.g.dart';

class SignInSignUpScreenHandler extends StatelessWidget {
  const SignInSignUpScreenHandler(
      {Key? key, required this.signInScreen, required this.signUpScreen})
      : super(key: key);

  final Widget signInScreen;
  final Widget signUpScreen;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

@TypedGoRoute<AuthRoute>(path: 'auth', routes: [
  TypedGoRoute<SignInRoute>(path: 'sign-in'),
  TypedGoRoute<SignUpRoute>(path: 'sign-up'),
])
class AuthRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const Placeholder();
  }
}

class SignInRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SignInPlaceholder();
  }
}

class SignUpRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SignInPlaceholder();
  }
}
