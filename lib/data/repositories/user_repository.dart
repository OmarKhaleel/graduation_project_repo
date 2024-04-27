import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:palmear_application/domain/entities/user_model.dart';

class UserRepository {
  final FirebaseFirestore firestore;

  UserRepository({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> addUser(UserModel user) async {
    await firestore.collection('users').doc(user.uid).set(user.toJson());
  }

  Future<UserModel?> getUser(String uid) async {
    DocumentSnapshot snapshot =
        await firestore.collection('users').doc(uid).get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      return UserModel.fromJson(data);
    }
    return null;
  }
}
