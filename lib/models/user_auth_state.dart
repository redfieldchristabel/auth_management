import 'package:auth_management/auth_management.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserAuthState extends ChangeNotifier {
  final WidgetRef? ref;
  final Stream<BaseUser?>? userStream;
  BaseUser? currentUser;

  UserAuthState({this.ref, this.userStream}) {
    if (ref != null) {
      ref!.listen(userNotifierProvider, (previous, next) {
        print('jalan listener');
        currentUser = next;
        notifyListeners();
      });
    } else if (userStream != null) {
      userStream!.listen((event) async {
        print('jalan listener');
        currentUser = event;
        notifyListeners();
      });
    }
  }
}
