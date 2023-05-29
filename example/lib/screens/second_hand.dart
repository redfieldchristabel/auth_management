import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SecondScreen extends StatelessWidget {
  const SecondScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("second screen")));
  }
}

class SecondRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SecondScreen();
  }
}
