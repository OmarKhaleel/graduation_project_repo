import 'package:geolocator/geolocator.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as toolkit;
import 'package:palmear_application/data/repositories/farm_repository.dart';
import 'package:palmear_application/data/services/user_services/user_session.dart';

Future<bool> isUserInsideFarmChecker(Position currentLocation) async {
  bool isUserInsideFarmValue = false;

  var sessionUser = UserSession().getUser();
  if (sessionUser != null) {
    var farmRepository = FarmRepository(userId: sessionUser.uid);
    var farms = await farmRepository.getFarms();

    if (farms.isNotEmpty) {
      for (var farm in farms) {
        isUserInsideFarmValue = toolkit.PolygonUtil.containsLocation(
          toolkit.LatLng(currentLocation.latitude, currentLocation.longitude),
          farm.locations
              .map((e) => toolkit.LatLng(e.latitude, e.longitude))
              .toList(),
          true,
        );
        if (isUserInsideFarmValue) {
          return true; // Exit early if inside a farm
        }
      }
    }
  }

  return isUserInsideFarmValue;
}
