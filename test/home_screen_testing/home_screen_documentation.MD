-This document outlines the testing strategy and implementation details for the Home Screen (MyHomePage) of the Palmear application, \
specifically focusing on the interaction with connected audio devices, such as the "palmear" device. The test verifies the
application's behavior when an audio device is connected, including UI updates and functionality related to audio device status, button
interactions, and the countdown timer feature.

A mock repository, TestAudioDeviceRepository, is used to simulate the retrieval of audio devices without requiring actual devices or
external services. This approach allows testing the Home Screen's reaction to different device connection states in a controlled
environment.

Steps:

Setup: The TestAudioDeviceRepository is initialized with a predefined set of devices, including a "palmear" device marked as connected.
Execution: The MyHomePage widget is rendered within a test environment, using the mock repository to simulate the device retrieval process.
Verification:
The connection status for the "palmear" device is accurately displayed on the UI.
The main action button changes appearance (e.g., turns red) and text (e.g., "Press to stop listening") upon interaction, reflecting the start of the listening session.
The countdown timer initiates at 50 seconds and decrements over time, resetting as appropriate based on user actions or the completion of the countdown.

Running the test: flutter test test/home_screen_testing/home_screen_test.dart
