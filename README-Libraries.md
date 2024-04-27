# app-dev

## Libraries

- FLutter package to record audio from microphone which utilizes native device audio manager: [https://pub.dev/packages/record](https://pub.dev/packages/record)
- Streaming of Pulse-code modulation (PCM) audio from Android and iOS with a customizable sampling rate: [https://pub.dev/packages/audio_streamer](https://pub.dev/packages/audio_streamer)
- Capture the audio stream buffer through microphone for iOS/Android: [https://pub.dev/packages/flutter_audio_capture](https://pub.dev/packages/flutter_audio_capture)
- A simple and efficient Fast Fourier Transform (FFT) library: [https://pub.dev/packages/fftea](https://pub.dev/packages/fftea)

### 1. UserSession

- _Location:_ user_session/user_session.dart
- _Description:_ This class implements the singleton pattern to manage the user session across the application. It ensures that only one instance of the user session exists, providing a global point of access to the user data.
- _Key Functionalities:_
  - setUser(UserModel user): Stores the UserModel instance representing the currently logged-in user.
  - getUser(): Retrieves the UserModel instance of the currently logged-in user, allowing other parts of the application to access user details.

### 2. UserModel

- _Location:_ firestore_services/user_model.dart
- _Description:_ Defines the data structure for user entities within the application. This model is used across the application to handle user information consistently.
- _Properties_:such as uid,name,locations to retrive it on the map.

### 3. UserRepository

- _Location:_ firestore_services/user_repository.dart
- _Description:_ Manages operations of storing and fetching users and user information.

### 4. MapScreen

- _Location:_ screens/map_screen.dart
- _Description:_ Displays a map interface allowing users to interact with various geographical features. It is integrated with functionalities like showing user location.

## Edited Files

### SignupService.dart

- _Location:_ services/signup_service.dart
- _Description:_ Handles the user signup to store the latlng locations as a list of geopoints in the firestore database.
