import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WithoutSignIn extends StatelessWidget {
  const WithoutSignIn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('aaaaaaaaaaaaaa')));
  }
}

class WithoutSignInRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const WithoutSignIn();
  }
}
