import 'package:auth_management/models/base_user.dart';
import 'package:auth_management/services/base_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A widget that handles authentication state and switches between two screens based on whether a user is authenticated or not.
///
/// [authScreen] The screen to display when a user is not authenticated.
/// [afterAuthScreen] The screen to display after a user is authenticated.
/// [authService] The authentication service to use. Normally the class are named by "AuthService"
/// and the class is must be extended from [BaseAuthService].
/// use Mason command "mason make auth_service to generate this service file.
class AuthScreenHandler<T extends BaseUser> extends ConsumerStatefulWidget {
  const AuthScreenHandler(
      {required this.authService,
      required this.authScreen,
      required this.afterAuthScreen,
      Key? key})
      : super(key: key);

  final Widget authScreen;
  final Widget afterAuthScreen;
  final BaseAuthService<T> authService;

  @override
  ConsumerState<AuthScreenHandler<T>> createState() =>
      _AuthScreenHandlerState<T>();
}

class _AuthScreenHandlerState<T extends BaseUser>
    extends ConsumerState<AuthScreenHandler<T>> {
  @override
  void initState() {
    // Stream userChanged = widget.authService.userStream();
    widget.authService.linkAuthWithProvider(ref);

    // userChanged.listen((newUser) {
    //   print('User exist: ${newUser != null}');
    //   if (newUser != null) {
    //     ref.watch(userNotifierProvider.notifier).signIn(newUser);
    //   } else {
    //     ref.watch(userNotifierProvider.notifier).signOut();
    //   }
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(userNotifierProvider) != null
        ? widget.afterAuthScreen
        : widget.authScreen;
  }
}
