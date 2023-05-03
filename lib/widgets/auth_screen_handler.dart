import 'package:auth_management/models/base_user.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_screen_handler.g.dart';

@riverpod
BaseUser? user(UserRef ref) {
 return null;
}


class AuthScreenHandler extends StatelessWidget {
  const AuthScreenHandler({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
