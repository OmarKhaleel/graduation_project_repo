import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:palmear_application/domain/entities/tree_model.dart';
import 'package:palmear_application/data/repositories/tree_repository.dart';

class TreeProvider with ChangeNotifier {
  List<TreeModel> _trees = [];
  final String userId;
  final String farmId;
  late final TreeRepository _treeRepository;

  TreeProvider(this.userId, this.farmId) {
    _treeRepository = TreeRepository(userId: userId, farmId: farmId);
    _fetchAndListenToTrees();
  }

  List<TreeModel> get trees => _trees;

  void _fetchAndListenToTrees() {
    _treeRepository.getTrees().then((treeList) {
      _trees = treeList;
      notifyListeners();
    });

    _treeRepository.getTreesStream().listen((treeList) {
      _trees = treeList;
      notifyListeners();
    }, onError: (error) {
      if (kDebugMode) {
        print('Error listening to tree updates: $error');
      }
    });
  }

  void updateTreeLocation(TreeModel tree, double latitude, double longitude) {
    TreeModel updatedTree = TreeModel(
      uid: tree.uid,
      label: tree.label,
      location: LatLng(latitude, longitude),
    );
    _treeRepository.addTree(updatedTree).then((_) {
      _fetchAndListenToTrees();
    }).catchError((error) {
      if (kDebugMode) {
        print('Error updating tree location: $error');
      }
    });
  }
}
