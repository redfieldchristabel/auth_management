import 'dart:async';

import 'package:auth_management/auth_management.dart';
import 'package:example/models/example_user.dart';
import 'package:example/screens/second_hand.dart';
import 'package:example/screens/without_signin.dart';
import 'package:example/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'main.dart';

part 'router.g.dart';

@TypedGoRoute<HomeRoute>(path: '/', routes: [
  TypedGoRoute<SecondRoute>(path: 'second'),
  TypedGoRoute<WithoutSignInRoute>(path: 'no-sign-in'),
])
class HomeRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return AuthScreenHandler<ExampleUser>(
      authService: authService,
      authScreen: const MyHomePage(
        title: 'auth screen',
      ),
      afterAuthScreen: Consumer(builder: (context, ref, _) {
        return MyHomePage(
          title: ref.watch(exampleUserProvider)?.username ?? " Tidak direkod",
        );
      }),
    );
  }
}
