import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:maps/models/places_autocomplete_model/places_autocomplete_model.dart';
import 'package:maps/models/places_details_model/places_details_model.dart';
import 'package:maps/utils/location_service.dart';
import 'package:maps/utils/places_autocomplete_service.dart';
import 'package:maps/utils/places_details_service.dart';

import 'package:maps/widgets/custom_text_field.dart';
import 'package:maps/widgets/list_of_predictions.dart';

class FlutterMapsView extends StatefulWidget {
  const FlutterMapsView({super.key});

  @override
  State<FlutterMapsView> createState() => _FlutterMapsViewState();
}

class _FlutterMapsViewState extends State<FlutterMapsView> {
  late PlacesAutocompleteService placesService;
  late PlacesDetailsService placesDetailsService;
  late TextEditingController textEditingController;
  late LocationService locationService;
  late MapController mapController;
  Marker? myLocationMarker;
  List<PlacesAutocompleteModel>places=[];
  //  late Location location;

  @override
  void initState() {
    textEditingController = TextEditingController();
    placesService = PlacesAutocompleteService();
    placesDetailsService = PlacesDetailsService();
    fetchPredictions();
    // location = Location();
    locationService = LocationService();
    mapController = MapController();
    updateCurrentLocation();
    // updateMyLocation();
    super.initState();
  }

  void fetchPredictions() {
    textEditingController.addListener(() async {
      if (textEditingController.text.isNotEmpty) {
        var result = await placesService.getPredictions(
          input: textEditingController.text,
        );
        places.clear();
        places.addAll(result);
        setState(() {
          
        });
      }else{
        places.clear();
        setState(() {
          
        });
      }
      // log(textEditingController.text);
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    // TODO: implement dispose
    super.dispose();
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
            initialZoom: 12,
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
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Column(
            children: [
              CustomTextField(textEditingController: textEditingController),
              SizedBox(height: 16,),
              ListOfPredictions(
                onPlaceSelected: (PlacesDetailsModel placeDetails) {
                  // هنا هتتعامل مع المكان اللي اتحدد
                  log('Selected Place: ${placeDetails.lat}');
            textEditingController.clear();
            places.clear();
            setState(() {});

                },
                placesDetails: placesDetailsService,
                itemCount: places.length,places: places,),
            ],
          ),
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

  void updateCurrentLocation() async {
    try {
      var locationData = await locationService.getLocation();
      setMyCameraPosition(locationData);
      setMarker(locationData);
    } on LocationServiceException catch (e) {
      // TODO
    } on LocationPermissionException catch (e) {
      // TODO
    } catch (e) {}
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
      mapController.camera.zoom,
    );
  }

  void setMarker(LocationData locationData) {
    setState(() {
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
