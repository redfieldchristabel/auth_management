import 'package:auth_management/models/base_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_screen_handler.g.dart';

@riverpod
BaseUser? user(UserRef ref) {
 return null;
}


class AuthScreenHandler extends ConsumerWidget {
  const AuthScreenHandler({required this.authScreen, required this.afterAuthScreen, Key? key}) : super(key: key);

  final Widget authScreen;
  final Widget afterAuthScreen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(userProvider) != null ? afterAuthScreen: authScreen;
  }
}
