import 'package:palmear_application/domain/entities/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:palmear_application/data/repositories/user_repository.dart';

class UserSession {
  static final UserSession _instance = UserSession._internal();
  UserModel? _currentUser;
  static const String _userKey = "current_user_id";

  factory UserSession() {
    return _instance;
  }

  UserSession._internal();

  Future<void> setUser(UserModel user) async {
    _currentUser = user;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, user.uid);
  }

  UserModel? getUser() {
    return _currentUser;
  }

  Future<void> loadUserFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString(_userKey);
    UserRepository userRepository = UserRepository();
    _currentUser = await userRepository.getUser(uid!);
  }

  Future<void> clearUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    _currentUser = null;
  }
}
