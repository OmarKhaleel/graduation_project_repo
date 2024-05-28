import 'package:geolocator/geolocator.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as toolkit;
import 'package:palmear_application/data/repositories/farm_repository.dart';
import 'package:palmear_application/data/repositories/tree_repository.dart';
import 'package:palmear_application/data/services/tree_services/tree_details.dart';
import 'package:palmear_application/data/services/user_services/user_session.dart';
import 'package:palmear_application/domain/entities/tree_model.dart';
import 'package:palmear_application/domain/use_cases/home_screen_use_cases/get_user_location.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/toast.dart';

Future<void> userInsideFarmOperations(
    TreeDetails treeDetails, String resultLabel) async {
  Position currentLocation = (await getUserLocation())!;
  var sessionUser = UserSession().getUser();
  if (sessionUser != null) {
    var farmRepository = FarmRepository(userId: sessionUser.uid);
    var farms = await farmRepository.getFarms();

    if (farms.isNotEmpty) {
      for (var farm in farms) {
        bool isUserInsideFarmValue = toolkit.PolygonUtil.containsLocation(
          toolkit.LatLng(currentLocation.latitude, currentLocation.longitude),
          farm.locations
              .map((e) => toolkit.LatLng(e.latitude, e.longitude))
              .toList(),
          true,
        );
        if (isUserInsideFarmValue) {
          var treeRepository =
              TreeRepository(userId: sessionUser.uid, farmId: farm.uid);
          List<TreeModel> trees = await treeRepository.getTrees();

          TreeModel? nearestTree;
          double nearestDistance = double.infinity;

          for (var tree in trees) {
            double distance = toolkit.SphericalUtil.computeDistanceBetween(
              toolkit.LatLng(
                  currentLocation.latitude, currentLocation.longitude),
              toolkit.LatLng(tree.location.latitude, tree.location.longitude),
            ).toDouble();

            if (distance < nearestDistance) {
              nearestTree = tree;
              nearestDistance = distance;
            }
          }

          if (nearestDistance > 4) {
            double latitude = currentLocation.latitude;
            double longitude = currentLocation.longitude;

            treeDetails.addTreeToUserFarm(
              resultLabel,
              latitude,
              longitude,
              farm.uid,
            );
          } else if (nearestTree != null) {
            treeDetails.updateSelectedTreeLabel(nearestTree.uid, resultLabel);
          } else {
            showToast(
                message:
                    "Something wrong happened when checking for nearby trees.");
          }
        } else {
          showToast(
              message:
                  "Something wrong happened when trying to locate your location.");
        }
      }
    }
  }
}
