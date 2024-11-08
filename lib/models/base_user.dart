import 'package:auth_management/services/base_auth.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'base_user.g.dart';

abstract class BaseUser {
  final String id;

  Id get isarId => BaseAuthService.fastHash(id);

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

  signIn(BaseUser user) {
    state = user;
  }

  void signOut() {
    state = null;
  }

  update(BaseUser user) {
    state = user;
  }
}
