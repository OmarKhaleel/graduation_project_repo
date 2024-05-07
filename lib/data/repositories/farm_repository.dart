import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:palmear_application/domain/entities/farm_model.dart';

class FarmRepository {
  final FirebaseFirestore firestore;
  final String userId;

  FarmRepository({FirebaseFirestore? firestore, required this.userId})
      : firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> addFarm(FarmModel farm) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('farms')
        .doc(farm.uid)
        .set(farm.toJson());
  }

  Future<List<FarmModel>> getFarms() async {
    QuerySnapshot querySnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('farms')
        .get();
    return querySnapshot.docs
        .map((doc) => FarmModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
