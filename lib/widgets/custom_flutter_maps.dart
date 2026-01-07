import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:maps/utils/location_service.dart';

class CustomFlutterMaps extends StatefulWidget {
  const CustomFlutterMaps({super.key});

  @override
  State<CustomFlutterMaps> createState() => _CustomFlutterMapsState();
}

class _CustomFlutterMapsState extends State<CustomFlutterMaps> {
  LocationService locationService = LocationService();
  MapController mapController = MapController();
  Marker? myLocationMarker;
  late Location location;
  @override
  void initState() {
    location = Location();
    // updateMyLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            // initialCameraFit: CameraFit.bounds(
            //   bounds: LatLngBounds.fromPoints([
            //     LatLng(30.582361879334343, 31.010437347372726),
            //     LatLng(30.53496088922579, 31.00533090113106),
            //   ]),
            // ),
            initialCenter: LatLng(30.551196212478537, 31.010724633040052),
            initialZoom: 10,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.maps',
            ),
            MarkerLayer(
              markers: [
                if (myLocationMarker != null)
                  myLocationMarker!, // ضيفيه لو موجود بس
                // ...staticPlaces, // لو عندك أماكن تانية ضيفيها هنا
              ],
            ),
          ],
        ),
        // Positioned(
        //   bottom: 16,
        //   right: 16,
        //   child: FloatingActionButton(
        //     child: Icon(Icons.add),
        //     onPressed: () {
        //       mapController.move(

        //         LatLng(30.40980795900272, 31.017127504150995),
        //         12,
        //       );
        //     },
        //   ),
        // ),
      ],
    );
  }

  // void updateMyLocation() async {
  //   await locationService.checkAndRequestLocationService();
  //   var hasPermission = await locationService
  //       .checkAndRequestLocationPermission();
  //   if (hasPermission) {
  //     locationService.getRealTimeLocationData((locationData) {
  //       if (locationData.latitude != null && locationData.longitude != null) {
  //         setMarker(locationData);

  //         // تحريك الكاميرا
  //         setMyCameraPosition(locationData);
  //       }
  //     });
  //   }
  // }

  void setMyCameraPosition(LocationData locationData) {
    mapController.move(
      LatLng(locationData.latitude!, locationData.longitude!),
      mapController
          .camera
          .zoom, // استخدمي الزووم الحالي بدل ما يرجع لـ 12 كل شوية
    );
  }

  void setMarker(LocationData locationData) {
    setState(() {
      // تحديث الماركر الوحيد بدل عمل add
      myLocationMarker = Marker(
        point: LatLng(locationData.latitude!, locationData.longitude!),
        width: 60,
        height: 60,
        alignment: Alignment.bottomCenter,
        child: Icon(Icons.location_on, color: Colors.red, size: 40),
      );
    });
  }
}

 

 // void getLocationData() {
  //   location.changeSettings(distanceFilter: 2);
  //   location.onLocationChanged.listen((locationData) {
  //     if (locationData.latitude != null && locationData.longitude != null) {
  //       setState(() {
  //         // تحديث الماركر الوحيد بدل عمل add
  //         myLocationMarker = Marker(
  //           point: LatLng(locationData.latitude!, locationData.longitude!),
  //           width: 60,
  //           height: 60,
  //           alignment: Alignment.bottomCenter,
  //           child: Icon(Icons.location_on, color: Colors.red, size: 40),
  //         );
  //       });

  //       // تحريك الكاميرا
  //       mapController.move(
  //         LatLng(locationData.latitude!, locationData.longitude!),
  //         mapController
  //             .camera
  //             .zoom, // استخدمي الزووم الحالي بدل ما يرجع لـ 12 كل شوية
  //       );
  //     }
  //   });
  // }


// world view zomm level from 0 to 3
// country view zomm level from 4 to 6
// city view from 10 to 12
// strret view from 13 to 17
// building view  from 18 to 20