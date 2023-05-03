import 'dart:ui';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'base_user.g.dart';

abstract class BaseUser {
  final Id id;
  final String username;
  final String email;

  BaseUser({required this.id, required this.username, required this.email});
}

@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  BaseUser? build() {
    return null;
  }

  logIn(BaseUser user) {
    state = user;
  }

  void logOut() {
    state = null;
  }

  update(BaseUser user){
    state = user;
  }
}
