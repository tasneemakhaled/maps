import 'package:geolocator/geolocator.dart'; // المكتبة الجديدة

class LocationService {
  
  // دالة جلب الموقع باستخدام geolocator
  Future<Position> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. فحص هل خدمة الموقع (GPS) مفتوحة؟
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // إذا كانت مغلقة نطلب من المستخدم فتحها
      throw LocationServiceException();
    }

    // 2. فحص التصاريح
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationPermissionException();
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw LocationPermissionException();
    }

    // 3. جلب الموقع الحالي
    return await Geolocator.getCurrentPosition();
  }
}

class LocationServiceException implements Exception {}
class LocationPermissionException implements Exception {}


/* الكود القديم باستخدام مكتبة location تم عمل كومنت له بناءً على طلبك
import 'package:location/location.dart';

class LocationService {
  Location location = Location();
  Future<void> checkAndRequestLocationService() async {
    var isServiceEnabled = await location.serviceEnabled();
    if (!isServiceEnabled) {
      isServiceEnabled = await location.requestService();
      if (!isServiceEnabled) {
        throw LocationServiceException();
      }
    }
  }

  Future<void> checkAndRequestLocationPermission() async {
    var permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.deniedForever) {
      throw LocationPermissionException();
    }
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();

      if (permissionStatus != PermissionStatus.granted) {
        throw LocationPermissionException();
      }
    }
  }

  void getRealTimeLocationData(void Function(LocationData)? onData) async {
    location.changeSettings(distanceFilter: 2);
    await checkAndRequestLocationService();
    await checkAndRequestLocationPermission();
    location.onLocationChanged.listen(onData);
  }

  Future<LocationData> getLocation() async {
    await checkAndRequestLocationService();
    await checkAndRequestLocationPermission();
    return await location.getLocation();
  }
}
*/


// import 'package:location/location.dart';

// class LocationService {
//   Location location = Location();
//   Future<void> checkAndRequestLocationService() async {
//     var isServiceEnabled = await location.serviceEnabled();
//     if (!isServiceEnabled) {
//       isServiceEnabled = await location.requestService();
//       if (!isServiceEnabled) {
//         throw LocationServiceException();
//       }
//     }
//   }

//   Future<void> checkAndRequestLocationPermission() async {
//     var permissionStatus = await location.hasPermission();
//     if (permissionStatus == PermissionStatus.deniedForever) {
//       throw LocationPermissionException();
//     }
//     if (permissionStatus == PermissionStatus.denied) {
//       permissionStatus = await location.requestPermission();

//       if (permissionStatus != PermissionStatus.granted) {
//         throw LocationPermissionException();
//       }
//     }
//   }

//   void getRealTimeLocationData(void Function(LocationData)? onData) async {
//     location.changeSettings(distanceFilter: 2);
//     await checkAndRequestLocationService();
//     await checkAndRequestLocationPermission();
//     location.onLocationChanged.listen(onData);
//   }

//   Future<LocationData> getLocation() async {
//     await checkAndRequestLocationService();
//     await checkAndRequestLocationPermission();
//     return await location.getLocation();
//   }
// }

// class LocationServiceException implements Exception {}

// class LocationPermissionException implements Exception {}

// // import 'package:location/location.dart';

// // class LocationService {
// //   Location location = Location();
// //   Future<bool> checkAndRequestLocationService() async {
// //     var isServiceEnabled = await location.serviceEnabled();
// //     if (!isServiceEnabled) {
// //       isServiceEnabled = await location.requestService();
// //       if (!isServiceEnabled) {
// //         return false;
// //       }
// //     }
// //     return true;
// //   }

// //   Future<bool> checkAndRequestLocationPermission() async {
// //     var permissionStatus = await location.hasPermission();
// //     if (permissionStatus == PermissionStatus.deniedForever) {
// //       return false;
// //     }
// //     if (permissionStatus == PermissionStatus.denied) {
// //       permissionStatus = await location.requestPermission();

// //       if (permissionStatus != PermissionStatus.granted) {
// //         return false;
// //       }
// //     }
// //     return true;
// //   }

// //   void getRealTimeLocationData(void Function(LocationData)? onData) {
// //     location.changeSettings(distanceFilter: 2);
// //     location.onLocationChanged.listen(onData);
// //   }

// // }
