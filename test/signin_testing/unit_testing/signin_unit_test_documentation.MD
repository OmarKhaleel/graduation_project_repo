- Introduction:
  This document provides an overview of the unit testing implemented for the authentication flow of the Palmear application. The purpose of these tests is to ensure the reliability and correctness of the sign-in and sign-up functionalities, which are central to the user experience.

- Test Description:
  The tests focus on two main scenarios within the authentication process: sign-in and sign-up. They aim to verify that the system behaves as expected when provided with both valid and invalid credentials.

- Code Description:
  The unit tests are written in Dart, using the flutter_test package for the Flutter framework. A FakeAuthService class simulates the behavior of the Firebase Authentication service to allow for isolated testing of the authentication logic without network dependencies.

- Test Function
  The FakeAuthService class provides two primary methods:

  1. signInWithEmailAndPassword: Simulates the sign-in process.
  2. signUpWithEmailAndPassword: Simulates the sign-up process.

- Test Assertions:
  Each test case includes assertions to confirm the behavior of the authentication methods:

  1. For a successful sign-in or sign-up, the test expects a return value of true.
  2. For an unsuccessful attempt, the test expects a return value of false or the appropriate exception to be thrown.

- Execution:

1. Run the Dart test file containing the provided test code.

   - Which could be done through the following command line in the terminal:
     flutter test test/signin_testing/unit_testing/signin_unit_test.dart
   - Or if you wish to test all testing files under the 'test' folder you do that through the following command line in the terminal:
     flutter test
     or
     flutter test test/

2. Observe the test output for pass status in green or fail status in red.

- Expected Result:
  The expected result for each test case is a Boolean indicator of success (true) or failure (false), matching the intended outcome for the given credentials.

- Error Handling:
  The tests include scenarios where errors are expected:

  1. Invalid Email: When a user attempts to sign up with an email that does not contain the @ symbol, the method should fail.
  2. Existing User: When a sign-up is attempted with an email already in use, the method should return false.
  3. Incorrect Password: If a sign-in is attempted with the wrong password, the method should fail.

- Conclusion:
  The unit tests for the Palmear application's authentication process are designed to ensure the security and robustness of user sign-ins and sign-ups. By using FakeAuthService to simulate Firebase Authentication, we can confidently verify our authentication logic in a variety of scenarios without the overhead of real network calls. This approach promotes a more reliable, maintainable, and testable codebase, which is essential for the overall quality of the application.
