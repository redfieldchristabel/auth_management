import 'dart:async';

import 'package:auth_management/auth_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

typedef GoROuterRedirectFunction = FutureOr<String?> Function(
    BuildContext, GoRouterState);

abstract class BaseAuthRouteService {
  String get homeRouteLocation;

  GoROuterRedirectFunction authGateFuncGenerator(
      {required WidgetRef ref, List<String>? excludeRoutes}) {
    return (BuildContext context, GoRouterState state) {
      print(state.fullPath);
      print("Aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
      final bool excludeScreenCheck =
          excludeRoutes?.any((element) => element == state.location) ?? false;

      if (ref.read(userNotifierProvider) == null && !excludeScreenCheck) {
        return homeRouteLocation;
      }
      return null;
    };
  }
}
