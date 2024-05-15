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

  // Method to fetch initial list of trees synchronously
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

  // Existing method to get real-time updates
  Stream<List<TreeModel>> getTreesStream() {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('farms')
        .doc(farmId)
        .collection('trees')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TreeModel.fromJson(doc.data()))
            .toList());
  }
}
