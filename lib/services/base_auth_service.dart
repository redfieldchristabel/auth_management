import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

abstract class BaseAuthService {
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

  void signIn() {}

  void signOut() {}
}
