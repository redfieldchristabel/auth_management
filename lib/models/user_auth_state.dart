import 'package:auth_management/auth_management.dart';
import 'package:flutter/cupertino.dart';

class UserAuthState extends ChangeNotifier {
  final Stream<BaseUser?> userStream;
  BaseUser? currentUser;

  UserAuthState(this.userStream) {
    userStream.listen((event) async {
      currentUser = event;
      notifyListeners();
    });
  }
}
