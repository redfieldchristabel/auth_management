import 'dart:ui';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'base_user.g.dart';

abstract class BaseUser {
  final String id;

  Id get isarId => fastHash(id);

  final String username;
  final String email;

  BaseUser({required this.id, required this.username, required this.email});

  /// FNV-1a 64bit hash algorithm optimized for Dart Strings
  int fastHash(String string) {
    var hash = 0xcbf29ce484222325;

    var i = 0;
    while (i < string.length) {
      final codeUnit = string.codeUnitAt(i++);
      hash ^= codeUnit >> 8;
      hash *= 0x100000001b3;
      hash ^= codeUnit & 0xFF;
      hash *= 0x100000001b3;
    }

    return hash;
  }
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


