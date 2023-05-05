import 'package:auth_management/auth_management.dart';
import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

abstract class BaseAuthService<T extends BaseUser> {
  static late Isar isar;

  /// Run this function at the first function that will run first during the start up of the application.
  /// Normally inside the main function
  static Future<void> initialize(CollectionSchema<dynamic> userSchema) async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [userSchema],
      directory: dir.path,
    );
  }

  /// an getter to retrieve user isar from project
  /// just override this function with your class isar database.
  IsarCollection<T> get usersIsar;

  /// an abstract function to generate an stream of current user
  /// return null of no current user
  Stream<T?> userStream() async* {
    yield await usersIsar.where().findFirst();
    await for (final event in usersIsar.watchLazy()) {
      T? user = await usersIsar.where().findFirst();
      yield user;
    }
  }

  /// A widget that register current user from the request param
  /// [user] a object that will be register as current user
  Future<void> addUserToCurrentAuth(T user) async {
    await isar.writeTxn(() async {
      await usersIsar.put(user);
    });
  }

  /// FNV-1a 64bit hash algorithm optimized for Dart Strings
  static int fastHash(String string) {
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

  /// A function to delete all user in the isar database for  [T] collection
  /// if you did override this function call the super method.
  @mustCallSuper
  Future<void> signOut() async {
    await usersIsar.where().deleteAll();
  }
}
