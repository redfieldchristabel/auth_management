import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

abstract class BaseAuthService {

  static late Isar isar;

  /// Run this function at the first function that will run first during the start up of the application.
  /// Normally inside the main function
  static Future<void> initialize (CollectionSchema<dynamic> userSchema) async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [userSchema],
      directory: dir.path,
    );
  }

  void signIn(){

  }

  void signOut(){

  }
}