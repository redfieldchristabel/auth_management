// import 'package:auth_management/auth_management.dart';
// import 'package:auth_management/services/base_auth_service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
//
// part 'auth_service_provider.g.dart';
//
// class AuthServiceProviderScope extends ConsumerStatefulWidget {
//   const AuthServiceProviderScope({
//     Key? key,
//     required this.authService,
//     required this.child,
//   }) : super(key: key);
//
//   final BaseAuthService authService;
//   final Widget child;
//
//   @override
//   ConsumerState<AuthServiceProviderScope> createState() =>
//       _AuthServiceProviderScopeState();
// }
//
// class _AuthServiceProviderScopeState
//     extends ConsumerState<AuthServiceProviderScope> {
//   @override
//   void initState() {
//     ref.watch(authServiceNotifierProvider.notifier).update(widget.authService);
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return widget.child;
//   }
// }
//
// @riverpod
// class AuthServiceNotifier extends _$AuthServiceNotifier {
//   @override
//   BaseAuthService? build() {
//     return null;
//   }
//
//   update(BaseAuthService authService) {
//     state = authService;
//   }
// }
