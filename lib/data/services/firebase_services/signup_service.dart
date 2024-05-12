import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:palmear_application/data/services/firebase_services/firebase_auth_services.dart';
import 'package:palmear_application/domain/entities/farm_model.dart';
import 'package:palmear_application/domain/entities/tree_model.dart';
import 'package:palmear_application/domain/entities/user_model.dart';
import 'package:palmear_application/data/repositories/farm_repository.dart';
import 'package:palmear_application/data/repositories/tree_repository.dart';
import 'package:palmear_application/data/repositories/user_repository.dart';
import 'package:palmear_application/presentation/screens/signin_screen.dart';

Future<void> signUp(
    BuildContext context,
    String email,
    String password,
    bool agreeToTerms,
    FirebaseAuthService auth,
    Function(String) setErrorMessage) async {
  final emailRegex = RegExp(r'^.+@.+\..+$');

  final passwordRegex = RegExp(r'^.{8,}$');

  if (email.isEmpty || password.isEmpty) {
    setErrorMessage("Email or password cannot be empty.");
    return;
  }

  if (!emailRegex.hasMatch(email)) {
    setErrorMessage("Email does not meet requirements.");
    return;
  }

  if (!passwordRegex.hasMatch(password)) {
    setErrorMessage("Password does not meet requirements.");
    return;
  }

  if (!agreeToTerms) {
    setErrorMessage("You must agree to the terms and conditions to proceed.");
    return;
  }

  try {
    User? user = await auth.signUpWithEmailAndPassword(email, password);
    if (user != null) {
      UserModel newUser = UserModel(uid: user.uid, email: email, name: '');

      UserRepository userRepository = UserRepository();
      await userRepository.addUser(newUser);

      FarmRepository farmRepository = FarmRepository(userId: user.uid);
      FarmModel newFarm = FarmModel(
          uid: FirebaseFirestore.instance.collection('farms').doc().id,
          name: 'Default Farm',
          locations: [
            // Test Map:
            const LatLng(31.991549, 35.878889),
            const LatLng(31.991896, 35.878791),
            const LatLng(31.992410, 35.878612),
            const LatLng(31.992539, 35.879559),
            const LatLng(31.992355, 35.879608),
            const LatLng(31.992171, 35.879646),
            const LatLng(31.992011, 35.879732),
            const LatLng(31.991850, 35.879830),
          ]);

      await farmRepository.addFarm(newFarm);

      TreeRepository treeRepository =
          TreeRepository(userId: user.uid, farmId: newFarm.uid);
      TreeModel newTree = TreeModel(
          uid: FirebaseFirestore.instance.collection('trees').doc().id,
          label: 'Healthy',
          location: const LatLng(31.991756, 35.879199));

      await treeRepository.addTree(newTree);

      newTree = TreeModel(
          uid: FirebaseFirestore.instance.collection('trees').doc().id,
          label: 'Infested',
          location: const LatLng(31.991771, 35.879330));

      await treeRepository.addTree(newTree);

      newTree = TreeModel(
          uid: FirebaseFirestore.instance.collection('trees').doc().id,
          label: 'Healthy',
          location: const LatLng(31.991796, 35.879486));

      await treeRepository.addTree(newTree);

      newTree = TreeModel(
          uid: FirebaseFirestore.instance.collection('trees').doc().id,
          label: 'Infested',
          location: const LatLng(31.991847, 35.879666));

      await treeRepository.addTree(newTree);

      newTree = TreeModel(
          uid: FirebaseFirestore.instance.collection('trees').doc().id,
          label: 'Healthy',
          location: const LatLng(31.992060, 35.879211));

      await treeRepository.addTree(newTree);

      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const SignInScreen()));
    } else {
      setErrorMessage("Registration failed. No user data available.");
    }
  } catch (e) {
    setErrorMessage("Error signing up: $e");
  }
}
