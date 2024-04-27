import 'package:palmear_application/domain/entities/user_model.dart';

class UserSession {
  static final UserSession _instance = UserSession._internal();
  UserModel? currentUser;

  factory UserSession() {
    return _instance;
  }

  UserSession._internal();

  void setUser(UserModel user) {
    currentUser = user;
  }

  UserModel? getUser() {
    return currentUser;
  }
}
