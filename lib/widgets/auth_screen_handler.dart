import 'package:auth_management/models/base_user.dart';
import 'package:auth_management/services/base_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthScreenHandler<T extends BaseUser> extends ConsumerStatefulWidget {
  const AuthScreenHandler(
      {required this.userStream,
      required this.authScreen,
      required this.afterAuthScreen,
      Key? key})
      : super(key: key);

  final Widget authScreen;
  final Widget afterAuthScreen;
  final Stream<T?> userStream;

  @override
  ConsumerState<AuthScreenHandler<T>> createState() =>
      _AuthScreenHandlerState<T>();
}

class _AuthScreenHandlerState<T extends BaseUser>
    extends ConsumerState<AuthScreenHandler<T>> {
  @override
  void initState() {
    Stream<T?> userChanged = widget.userStream;
    userChanged.listen((newUser) {
      print('User exist: ${newUser != null}');
      if (newUser != null) {
        ref.watch(userNotifierProvider.notifier).signIn(newUser);
      } else {
        ref.watch(userNotifierProvider.notifier).signOut();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(userNotifierProvider) != null
        ? widget.afterAuthScreen
        : widget.authScreen;
  }
}
