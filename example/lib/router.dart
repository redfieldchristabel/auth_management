
import 'package:example/models/example_user.dart';
import 'package:example/screens/second_hand.dart';
import 'package:example/screens/without_signin.dart';
import 'package:example/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

part 'router.g.dart';

@TypedGoRoute<HomeRoute>(
  path: '/',
  routes: [
    TypedGoRoute<SecondRoute>(path: 'second'),
    TypedGoRoute<WithoutSignInRoute>(path: 'no-sign-in'),
  ],
)
class HomeRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer(builder: (context, ref, _) {
              return Text(ref.watch(exampleUserProvider)?.id ?? 'sdesdsds');
            }),
            TextButton(
                onPressed: authService.signOut, child: const Text('sign-out')),
            TextButton(
                onPressed: () => SecondRoute().go(context),
                child: const Text('second screen')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: authService.firebaseAuth.signInAnonymously,
      ),
    );
  }
}
