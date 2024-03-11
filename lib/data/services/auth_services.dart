class AuthService {
  final String _mockEmail = "example123@gmail.com";
  final String _mockPassword = "123";

  AuthService();

  Future<bool> authenticate(String email, String password) async {
    // Explicitly handle the case where email or password is empty
    if (email.isEmpty || password.isEmpty) {
      return false;
    }

    // Check if the credentials match the mock credentials
    if (email == _mockEmail && password == _mockPassword) {
      // Credentials match
      return true;
    } else {
      // Credentials don't match
      return false;
    }
  }
}
