import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:palmear_application/domain/entities/tree_model.dart';

class TreeRepository {
  final FirebaseFirestore firestore;
  final String userId;
  final String farmId;

  TreeRepository(
      {FirebaseFirestore? firestore,
      required this.userId,
      required this.farmId})
      : firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> addTree(TreeModel tree) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('farms')
        .doc(farmId)
        .collection('trees')
        .doc(tree.uid)
        .set(tree.toJson());
  }

  Future<List<TreeModel>> getTrees() async {
    QuerySnapshot querySnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('farms')
        .doc(farmId)
        .collection('trees')
        .get();
    return querySnapshot.docs
        .map((doc) => TreeModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
