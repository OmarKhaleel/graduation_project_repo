class FakeAuthService {
  final Map<String, String> _users = {}; // Simulate a user database

  Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    if (!_users.containsKey(email) && email.contains("@")) {
      _users[email] = password; // Simulate saving the user
      return true;
    }
    return false; // User already exists or email is invalid
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    // Check if the user exists and password matches
    return _users[email] == password;
  }

  bool isUserSaved(String email) {
    return _users.containsKey(email);
  }
}
