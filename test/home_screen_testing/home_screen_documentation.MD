-This document outlines the testing strategy and implementation details for the Home Screen (MyHomePage) of the Palmear application, \
specifically focusing on the interaction with connected audio devices, such as the "km_b2 digital audio" device when running on an android emulator/physical device and "external microphone" when running on an IOS emulator/physical device, these are names for the "Palmear Audio Amplifier" which is used in our application and recognized on different platforms but in different names, so we check the platform we are running on then we look for the specified name of the device for the platform. The test verifies the application's behavior when an audio device is connected, including UI updates and functionality related to audio device status, button interactions, and the countdown timer feature.

A mock repository, TestAudioDeviceRepository, is used to simulate the retrieval of audio devices without requiring actual devices or
external services. This approach allows testing the Home Screen's reaction to different device connection states in a controlled
environment.

Steps:

Setup: The TestAudioDeviceRepository is initialized with a predefined set of devices, including a "km_b2 digital audio" and "external microphone" devices marked as connected.
Execution: The MyHomePage widget is rendered within a test environment, using the mock repository to simulate the device retrieval process.
Verification:
The connection status for the "Palmear Audio Amplifier" device is accurately displayed on the UI.
The main action button changes the icon's appearance (e.g., turns white) and text (e.g., "Press to stop listening") upon interaction, reflecting the start of the listening session.
The countdown timer initiates at 50 seconds and decrements over time, resetting as appropriate based on user actions or the completion of the countdown.

Running the test: flutter test test/home_screen_testing/home_screen_test.dart
