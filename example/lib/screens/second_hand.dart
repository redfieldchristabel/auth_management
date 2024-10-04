import 'package:example/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Text("second screen")),
      floatingActionButton:
          FloatingActionButton(onPressed: authService.signOut),
    );
  }
}

class SecondRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SecondScreen();
  }
}
