import 'dart:developer';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;
import 'package:maps/models/places_autocomplete_model/places_autocomplete_model.dart';
import 'package:maps/models/places_details_model/places_details_model.dart';
import 'package:maps/utils/location_service.dart';
import 'package:maps/utils/places_autocomplete_service.dart';
import 'package:maps/utils/places_details_service.dart';
import 'package:maps/utils/routes_service.dart'; 

import 'package:maps/widgets/custom_text_field.dart';
import 'package:maps/widgets/list_of_predictions.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  
  // --- إضافة FocusNode هنا ---
  final FocusNode _focusNode = FocusNode();
  
  Marker? myLocationMarker;
  Marker? destinationMarker; 
  List<PlacesAutocompleteModel> places = [];
  List<LatLng> routePoints = [];
  
  List<PlacesAutocompleteModel> searchHistory = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState(); 
    textEditingController = TextEditingController();
    placesService = PlacesAutocompleteService();
    placesDetailsService = PlacesDetailsService();
    locationService = LocationService();
    mapController = MapController();
    
    _loadSearchHistory();
    fetchPredictions();
    updateCurrentLocation();

    // إضافة مستمع للـ Focus عشان نحدث الواجهة لما المستخدم يضغط على الفيلد
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? historyData = prefs.getStringList('search_history');
    if (historyData != null) {
      setState(() {
        searchHistory = historyData.map((item) => 
          PlacesAutocompleteModel.fromJson(json.decode(item))).toList();
      });
    }
  }

  Future<void> _saveToHistory(PlacesAutocompleteModel place) async {
    final prefs = await SharedPreferences.getInstance();
    searchHistory.removeWhere((element) => element.displayName == place.displayName);
    searchHistory.insert(0, place);
    if (searchHistory.length > 10) searchHistory.removeLast();

    List<String> historyData = searchHistory.map((item) => 
      json.encode(item.toJson())).toList();
    await prefs.setStringList('search_history', historyData);
    setState(() {});
  }

  void fetchPredictions() {
    textEditingController.addListener(() async {
      if (textEditingController.text.isNotEmpty) {
        setState(() => isSearching = true);
        var result = await placesService.getPredictions(
          input: textEditingController.text,
        );
        places.clear();
        places.addAll(result);
        setState(() {});
      } else {
        setState(() => isSearching = false);
        places.clear();
        setState(() {});
      }
    });
  }

  void getAndDrawRoute(LatLng destination) async {
    if (myLocationMarker == null) return;
    try {
      final points = await RouteService.fetchRoute(
        myLocationMarker!.point, 
        destination
      );
      if (points.isNotEmpty) {
        setState(() { routePoints = points; });
        final bounds = LatLngBounds.fromPoints(routePoints);
        mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds, 
            padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 50),
          ),
        );
      }
    } catch (e) { log("Error drawing route: $e"); }
  }

  @override
  void dispose() {
    textEditingController.dispose();
    _focusNode.dispose(); // مسح الـ FocusNode
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: updateCurrentLocation,
        child: const Icon(Icons.my_location, color: Colors.blueAccent),
      ),
      body: GestureDetector(
        // عشان لما يضغط في أي مكان على الخريطة يقفل القائمة والكيبورد
        onTap: () {
          _focusNode.unfocus();
        },
        child: Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: LatLng(30.551196, 31.010724),
                initialZoom: 12,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                ),
                PolylineLayer(
                  polylines: [
                    if (routePoints.isNotEmpty)
                      Polyline(
                        points: routePoints,
                        color: const Color(0xFF2196F3), 
                        strokeWidth: 5.0,
                        strokeCap: StrokeCap.round, 
                        strokeJoin: StrokeJoin.round,
                      ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    if (myLocationMarker != null)
                      Marker(
                        point: myLocationMarker!.point,
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Container(
                              width: 15,
                              height: 15,
                              decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                            ),
                          ),
                        ),
                      ),
                    if (destinationMarker != null) destinationMarker!,
                  ],
                ),
              ],
            ),
            
            Positioned(
              top: 50, 
              left: 16,
              right: 16,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)
                      ],
                    ),
                    // تمرير الـ focusNode للتكست فيلد
                    child: CustomTextField(
                      textEditingController: textEditingController,
                      focusNode: _focusNode, // تأكدي إن CustomTextField بيستقبل focusNode
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // --- التعديل الجوهري هنا ---
                  // القائمة تظهر فقط لو الحقل عليه Focus
                  if (_focusNode.hasFocus)
                    ListOfPredictions(
                      onPlaceSelected: (PlacesDetailsModel placeDetails) {
                        double lat = double.parse(placeDetails.lat.toString());
                        double lon = double.parse(placeDetails.lon.toString());
                        LatLng destinationLatLng = LatLng(lat, lon);

                        setState(() {
                          destinationMarker = Marker(
                            point: destinationLatLng,
                            width: 60,
                            height: 60,
                            alignment: Alignment.topCenter, 
                            child: const Icon(Icons.location_on, color: Colors.redAccent, size: 45),
                          );
                        });

                        getAndDrawRoute(destinationLatLng);
                        
                        _saveToHistory(PlacesAutocompleteModel(
                          displayName: placeDetails.displayName,
                          lat: placeDetails.lat.toString(),
                          lon: placeDetails.lon.toString(),
                        ));

                        textEditingController.clear();
                        places.clear();
                        _focusNode.unfocus(); // إغلاق القائمة بعد الاختيار
                        setState(() {});
                      },
                      placesDetails: placesDetailsService,
                      itemCount: isSearching ? places.length : searchHistory.length,
                      places: isSearching ? places : searchHistory,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void updateCurrentLocation() async {
    try {
      Position position = await locationService.getLocation();
      setMarker(position);
      setMyCameraPosition(position);
    } catch (e) { log("Location Error: $e"); }
  }

  void setMyCameraPosition(Position position) {
    mapController.move(LatLng(position.latitude, position.longitude), 15.0);
  }

  void setMarker(Position position) {
    setState(() {
      myLocationMarker = Marker(
        point: LatLng(position.latitude, position.longitude),
        width: 40, height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2), shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: Container(width: 15, height: 15, decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle)),
          ),
        ),
      );
    });
  }
}


// import 'dart:developer';
// import 'dart:convert'; // أضيفي هذا للتعامل مع الـ JSON
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:location/location.dart' as loc;
// import 'package:maps/models/places_autocomplete_model/places_autocomplete_model.dart';
// import 'package:maps/models/places_details_model/places_details_model.dart';
// import 'package:maps/utils/location_service.dart';
// import 'package:maps/utils/places_autocomplete_service.dart';
// import 'package:maps/utils/places_details_service.dart';
// import 'package:maps/utils/routes_service.dart'; 

// import 'package:maps/widgets/custom_text_field.dart';
// import 'package:maps/widgets/list_of_predictions.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // أضيفي هذا

// class FlutterMapsView extends StatefulWidget {
//   const FlutterMapsView({super.key});

//   @override
//   State<FlutterMapsView> createState() => _FlutterMapsViewState();
// }

// class _FlutterMapsViewState extends State<FlutterMapsView> {
//   late PlacesAutocompleteService placesService;
//   late PlacesDetailsService placesDetailsService;
//   late TextEditingController textEditingController;
//   late LocationService locationService;
//   late MapController mapController;
  
//   Marker? myLocationMarker;
//   Marker? destinationMarker; 
//   List<PlacesAutocompleteModel> places = [];
//   List<LatLng> routePoints = [];
  
//   // متغيرات الـ History
//   List<PlacesAutocompleteModel> searchHistory = [];
//   bool isSearching = false;

//   @override
//   void initState() {
//     super.initState(); 
//     textEditingController = TextEditingController();
//     placesService = PlacesAutocompleteService();
//     placesDetailsService = PlacesDetailsService();
//     locationService = LocationService();
//     mapController = MapController();
    
//     _loadSearchHistory(); // تحميل السجل عند البداية
//     fetchPredictions();
//     updateCurrentLocation();
//   }

//   // دالة تحميل السجل من ذاكرة الهاتف
//   Future<void> _loadSearchHistory() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String>? historyData = prefs.getStringList('search_history');
//     if (historyData != null) {
//       setState(() {
//         searchHistory = historyData.map((item) => 
//           PlacesAutocompleteModel.fromJson(json.decode(item))).toList();
//       });
//     }
//   }

//   // دالة حفظ مكان جديد في السجل
//   Future<void> _saveToHistory(PlacesAutocompleteModel place) async {
//     final prefs = await SharedPreferences.getInstance();
//     // منع التكرار: لو المكان موجود نمسحه ونحطه في الأول
//     searchHistory.removeWhere((element) => element.displayName == place.displayName);
//     searchHistory.insert(0, place);
    
//     // حفظ آخر 10 عمليات بحث فقط
//     if (searchHistory.length > 10) searchHistory.removeLast();

//     List<String> historyData = searchHistory.map((item) => 
//       json.encode(item.toJson())).toList();
//     await prefs.setStringList('search_history', historyData);
//     setState(() {});
//   }

//   void fetchPredictions() {
//     textEditingController.addListener(() async {
//       if (textEditingController.text.isNotEmpty) {
//         setState(() => isSearching = true);
//         var result = await placesService.getPredictions(
//           input: textEditingController.text,
//         );
//         places.clear();
//         places.addAll(result);
//         setState(() {});
//       } else {
//         setState(() => isSearching = false);
//         places.clear();
//         setState(() {});
//       }
//     });
//   }

//   void getAndDrawRoute(LatLng destination) async {
//     if (myLocationMarker == null) return;

//     try {
//       final points = await RouteService.fetchRoute(
//         myLocationMarker!.point, 
//         destination
//       );

//       if (points.isNotEmpty) {
//         setState(() {
//           routePoints = points;
//         });

//         final bounds = LatLngBounds.fromPoints(routePoints);
//         mapController.fitCamera(
//           CameraFit.bounds(
//             bounds: bounds, 
//             padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 50),
//           ),
//         );
//       }
//     } catch (e) {
//       log("Error drawing route: $e");
//     }
//   }

//   @override
//   void dispose() {
//     textEditingController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold( 
//       // إضافة الـ Floating Action Button لتحديث الموقع
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.white,
//         onPressed: updateCurrentLocation,
//         child: const Icon(Icons.my_location, color: Colors.blueAccent),
//       ),
//       body: Stack(
//         children: [
//           FlutterMap(
//             mapController: mapController,
//             options: MapOptions(
//               initialCenter: LatLng(30.551196, 31.010724),
//               initialZoom: 12,
//             ),
//             children: [
//               TileLayer(
//                 urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
//                 subdomains: const ['a', 'b', 'c', 'd'],
//               ),
              
//               PolylineLayer(
//                 polylines: [
//                   if (routePoints.isNotEmpty)
//                     Polyline(
//                       points: routePoints,
//                       color: const Color(0xFF2196F3), 
//                       strokeWidth: 5.0,
//                       strokeCap: StrokeCap.round, 
//                       strokeJoin: StrokeJoin.round,
//                     ),
//                 ],
//               ),

//               MarkerLayer(
//                 markers: [
//                   if (myLocationMarker != null)
//                     Marker(
//                       point: myLocationMarker!.point,
//                       width: 40,
//                       height: 40,
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Colors.blue.withOpacity(0.2),
//                           shape: BoxShape.circle,
//                           border: Border.all(color: Colors.white, width: 2),
//                         ),
//                         child: Center(
//                           child: Container(
//                             width: 15,
//                             height: 15,
//                             decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
//                           ),
//                         ),
//                       ),
//                     ),

//                   if (destinationMarker != null) destinationMarker!,
//                 ],
//               ),
//             ],
//           ),
          
//           Positioned(
//             top: 50, 
//             left: 16,
//             right: 16,
//             child: Column(
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                     boxShadow: [
//                       BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)
//                     ],
//                   ),
//                   child: CustomTextField(textEditingController: textEditingController),
//                 ),
//                 const SizedBox(height: 8),
//                 ListOfPredictions(
//                   onPlaceSelected: (PlacesDetailsModel placeDetails) {
//                     double lat = double.parse(placeDetails.lat.toString());
//                     double lon = double.parse(placeDetails.lon.toString());
//                     LatLng destinationLatLng = LatLng(lat, lon);

//                     setState(() {
//                       destinationMarker = Marker(
//                         point: destinationLatLng,
//                         width: 60,
//                         height: 60,
//                         alignment: Alignment.topCenter, 
//                         child: const Icon(
//                           Icons.location_on, 
//                           color: Colors.redAccent, 
//                           size: 45,
//                           shadows: [Shadow(blurRadius: 10, color: Colors.black26)],
//                         ),
//                       );
//                     });

//                     getAndDrawRoute(destinationLatLng);
                    
//                     // حفظ في السجل عند اختيار مكان
//                     _saveToHistory(PlacesAutocompleteModel(
//                       displayName: placeDetails.displayName,
//                       lat: placeDetails.lat.toString(),
//                       lon: placeDetails.lon.toString(),
//                     ));

//                     textEditingController.clear();
//                     places.clear();
//                     setState(() {});
//                   },
//                   placesDetails: placesDetailsService,
//                   // إذا كان يبحث نعرض النتائج، إذا كان الحقل فارغ نعرض السجل
//                   itemCount: isSearching ? places.length : searchHistory.length,
//                   places: isSearching ? places : searchHistory,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//  void updateCurrentLocation() async {
//   try {
//     Position position = await locationService.getLocation();
//     setMarker(position);
//     setMyCameraPosition(position);
//   } catch (e) {
//     log("Location Error: $e");
//   }
// }

// void setMyCameraPosition(Position position) {
//   mapController.move(
//     LatLng(position.latitude, position.longitude),
//     15.0,
//   );
// }

// void setMarker(Position position) {
//   setState(() {
//     myLocationMarker = Marker(
//       point: LatLng(position.latitude, position.longitude),
//       width: 40,
//       height: 40,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.blue.withOpacity(0.2),
//           shape: BoxShape.circle,
//           border: Border.all(color: Colors.white, width: 2),
//         ),
//         child: Center(
//           child: Container(
//             width: 15,
//             height: 15,
//             decoration: const BoxDecoration(
//               color: Colors.blue,
//               shape: BoxShape.circle,
//             ),
//           ),
//         ),
//       ),
//     );
//   });
// }
// }




// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:location/location.dart' as loc;
// import 'package:maps/models/places_autocomplete_model/places_autocomplete_model.dart';
// import 'package:maps/models/places_details_model/places_details_model.dart';
// import 'package:maps/utils/location_service.dart';
// import 'package:maps/utils/places_autocomplete_service.dart';
// import 'package:maps/utils/places_details_service.dart';
// import 'package:maps/utils/routes_service.dart'; 

// import 'package:maps/widgets/custom_text_field.dart';
// import 'package:maps/widgets/list_of_predictions.dart';

// class FlutterMapsView extends StatefulWidget {
//   const FlutterMapsView({super.key});

//   @override
//   State<FlutterMapsView> createState() => _FlutterMapsViewState();
// }

// class _FlutterMapsViewState extends State<FlutterMapsView> {
//   late PlacesAutocompleteService placesService;
//   late PlacesDetailsService placesDetailsService;
//   late TextEditingController textEditingController;
//   late LocationService locationService;
//   late MapController mapController;
  
//   Marker? myLocationMarker;
//   Marker? destinationMarker; 
//   List<PlacesAutocompleteModel> places = [];
//   List<LatLng> routePoints = [];

//   @override
//   void initState() {
//     super.initState(); // يفضل دائماً استدعاء super في البداية
//     textEditingController = TextEditingController();
//     placesService = PlacesAutocompleteService();
//     placesDetailsService = PlacesDetailsService();
//     locationService = LocationService();
//     mapController = MapController();
    
//     fetchPredictions();
    
//     // طلب الموقع عند بدء التطبيق
//     updateCurrentLocation();
//   }

//   void fetchPredictions() {
//     textEditingController.addListener(() async {
//       if (textEditingController.text.isNotEmpty) {
//         var result = await placesService.getPredictions(
//           input: textEditingController.text,
//         );
//         places.clear();
//         places.addAll(result);
//         setState(() {});
//       } else {
//         places.clear();
//         setState(() {});
//       }
//     });
//   }

//   // دالة رسم الطريق مع تحسينات بصرية
//   void getAndDrawRoute(LatLng destination) async {
//     if (myLocationMarker == null) return;

//     try {
//       // هنا نستخدم RouteService (الذي يستخدم geolocator)
//       final points = await RouteService.fetchRoute(
//         myLocationMarker!.point, 
//         destination
//       );

//       if (points.isNotEmpty) {
//         setState(() {
//           routePoints = points;
//         });

//         final bounds = LatLngBounds.fromPoints(routePoints);
//         mapController.fitCamera(
//           CameraFit.bounds(
//             bounds: bounds, 
//             padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 50),
//           ),
//         );
//       }
//     } catch (e) {
//       log("Error drawing route: $e");
//     }
//   }

//   @override
//   void dispose() {
//     textEditingController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold( // أضفت Scaffold لضمان ظهور الـ SnackBar والـ Layout بشكل صحيح
//       body: Stack(
//         children: [
//           FlutterMap(
//             mapController: mapController,
//             options: MapOptions(
//               initialCenter: LatLng(30.551196, 31.010724),
//               initialZoom: 12,
//             ),
//             children: [
//               TileLayer(
//                 urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
//                 subdomains: const ['a', 'b', 'c', 'd'],
//               ),
              
//               PolylineLayer(
//                 polylines: [
//                   if (routePoints.isNotEmpty)
//                     Polyline(
//                       points: routePoints,
//                       color: const Color(0xFF2196F3), 
//                       strokeWidth: 5.0,
//                       strokeCap: StrokeCap.round, 
//                       strokeJoin: StrokeJoin.round,
//                     ),
//                 ],
//               ),

//               MarkerLayer(
//                 markers: [
//                   if (myLocationMarker != null)
//                     Marker(
//                       point: myLocationMarker!.point,
//                       width: 40,
//                       height: 40,
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Colors.blue.withOpacity(0.2),
//                           shape: BoxShape.circle,
//                           border: Border.all(color: Colors.white, width: 2),
//                         ),
//                         child: Center(
//                           child: Container(
//                             width: 15,
//                             height: 15,
//                             decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
//                           ),
//                         ),
//                       ),
//                     ),

//                   if (destinationMarker != null) destinationMarker!,
//                 ],
//               ),
//             ],
//           ),
          
//           Positioned(
//             top: 50, // أبعدناه عن الحافة العلوية قليلاً
//             left: 16,
//             right: 16,
//             child: Column(
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                     boxShadow: [
//                       BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)
//                     ],
//                   ),
//                   child: CustomTextField(textEditingController: textEditingController),
//                 ),
//                 const SizedBox(height: 8),
//                 ListOfPredictions(
//                   onPlaceSelected: (PlacesDetailsModel placeDetails) {
//                    double lat = double.parse(placeDetails.lat.toString());
//   double lon = double.parse(placeDetails.lon.toString());
  
//   LatLng destinationLatLng = LatLng(lat, lon);

//                     setState(() {
//                       destinationMarker = Marker(
//                         point: destinationLatLng,
//                         width: 60,
//                         height: 60,
//                         alignment: Alignment.topCenter, 
//                         child: const Icon(
//                           Icons.location_on, 
//                           color: Colors.redAccent, 
//                           size: 45,
//                           shadows: [Shadow(blurRadius: 10, color: Colors.black26)],
//                         ),
//                       );
//                     });

//                     getAndDrawRoute(destinationLatLng);
//                     textEditingController.clear();
//                     places.clear();
//                     setState(() {});
//                   },
//                   placesDetails: placesDetailsService,
//                   itemCount: places.length,
//                   places: places,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//  void updateCurrentLocation() async {
//   try {
//     // جلب الموقع باستخدام geolocator
//     Position position = await locationService.getLocation();
    
//     // تحديث الماركر والكاميرا
//     setMarker(position);
//     setMyCameraPosition(position);
//   } catch (e) {
//     log("Location Error: $e");
//   }
// }

// // 3. تعديل دالة setMyCameraPosition لتستقبل Position
// void setMyCameraPosition(Position position) {
//   mapController.move(
//     LatLng(position.latitude, position.longitude),
//     15.0,
//   );
// }

// // 4. تعديل دالة setMarker لتستقبل Position
// void setMarker(Position position) {
//   setState(() {
//     myLocationMarker = Marker(
//       point: LatLng(position.latitude, position.longitude),
//       width: 40,
//       height: 40,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.blue.withOpacity(0.2),
//           shape: BoxShape.circle,
//           border: Border.all(color: Colors.white, width: 2),
//         ),
//         child: Center(
//           child: Container(
//             width: 15,
//             height: 15,
//             decoration: const BoxDecoration(
//               color: Colors.blue,
//               shape: BoxShape.circle,
//             ),
//           ),
//         ),
//       ),
//     );
//   });
// }
// }





// // import 'dart:developer';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_map/flutter_map.dart';
// // import 'package:latlong2/latlong.dart';
// // import 'package:location/location.dart' as loc;
// // import 'package:maps/models/places_autocomplete_model/places_autocomplete_model.dart';
// // import 'package:maps/models/places_details_model/places_details_model.dart';
// // import 'package:maps/utils/location_service.dart';
// // import 'package:maps/utils/places_autocomplete_service.dart';
// // import 'package:maps/utils/places_details_service.dart';
// // import 'package:maps/utils/routes_service.dart';

// // import 'package:maps/widgets/custom_text_field.dart';
// // import 'package:maps/widgets/list_of_predictions.dart';

// // class FlutterMapsView extends StatefulWidget {
// //   const FlutterMapsView({super.key});

// //   @override
// //   State<FlutterMapsView> createState() => _FlutterMapsViewState();
// // }

// // class _FlutterMapsViewState extends State<FlutterMapsView> {
// //   late PlacesAutocompleteService placesService;
// //   late PlacesDetailsService placesDetailsService;
// //   late TextEditingController textEditingController;
// //   late LocationService locationService;
// //   late MapController mapController;
  
// //   Marker? myLocationMarker;
// //   Marker? destinationMarker; 
// //   List<PlacesAutocompleteModel> places = [];
// //   List<LatLng> routePoints = [];

// //   @override
// //   void initState() {
// //     super.initState();
// //     textEditingController = TextEditingController();
// //     placesService = PlacesAutocompleteService();
// //     placesDetailsService = PlacesDetailsService();
// //     locationService = LocationService();
// //     mapController = MapController();
    
// //     fetchPredictions();
    
// //     // تنفيذ جلب الموقع بعد بناء أول Frame للتطبيق لضمان ظهور الرسالة
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       updateCurrentLocation();
// //     });
// //   }

// //   void fetchPredictions() {
// //     textEditingController.addListener(() async {
// //       if (textEditingController.text.isNotEmpty) {
// //         var result = await placesService.getPredictions(
// //           input: textEditingController.text,
// //         );
// //         places.clear();
// //         places.addAll(result);
// //         setState(() {});
// //       } else {
// //         places.clear();
// //         setState(() {});
// //       }
// //     });
// //   }

// //   void getAndDrawRoute(LatLng destination) async {
// //     if (myLocationMarker == null) return;

// //     try {
// //       final points = await RouteService.fetchRoute(
// //         myLocationMarker!.point, 
// //         destination
// //       );

// //       if (points.isNotEmpty) {
// //         setState(() {
// //           routePoints = points;
// //         });

// //         final bounds = LatLngBounds.fromPoints(routePoints);
// //         mapController.fitCamera(
// //           CameraFit.bounds(
// //             bounds: bounds, 
// //             padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 50),
// //           ),
// //         );
// //       }
// //     } catch (e) {
// //       log("Error drawing route: $e");
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     textEditingController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold( // أضفت Scaffold لضمان استقرار الواجهة
// //       body: Stack(
// //         children: [
// //           FlutterMap(
// //             mapController: mapController,
// //             options: MapOptions(
// //               initialCenter: LatLng(30.551196, 31.010724),
// //               initialZoom: 12,
// //             ),
// //             children: [
// //               TileLayer(
// //                 urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
// //                 subdomains: const ['a', 'b', 'c', 'd'],
// //               ),
// //               PolylineLayer(
// //                 polylines: [
// //                   if (routePoints.isNotEmpty)
// //                     Polyline(
// //                       points: routePoints,
// //                       color: const Color(0xFF2196F3),
// //                       strokeWidth: 5.0,
// //                       strokeCap: StrokeCap.round,
// //                       strokeJoin: StrokeJoin.round,
// //                     ),
// //                 ],
// //               ),
// //               MarkerLayer(
// //                 markers: [
// //                   if (myLocationMarker != null) myLocationMarker!,
// //                   if (destinationMarker != null) destinationMarker!,
// //                 ],
// //               ),
// //             ],
// //           ),
          
// //           Positioned(
// //             top: 50, // أبعدناه قليلاً عن الحافة العلوية
// //             left: 16,
// //             right: 16,
// //             child: Column(
// //               children: [
// //                 Container(
// //                   decoration: BoxDecoration(
// //                     color: Colors.white,
// //                     borderRadius: BorderRadius.circular(8),
// //                     boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
// //                   ),
// //                   child: CustomTextField(textEditingController: textEditingController),
// //                 ),
// //                 const SizedBox(height: 8),
// //                 if (places.isNotEmpty)
// //                   ListOfPredictions(
// //                     onPlaceSelected: (PlacesDetailsModel placeDetails) {
// //                       LatLng destinationLatLng = LatLng(
// //                         double.parse(placeDetails.lat.toString()), 
// //                         double.parse(placeDetails.lon.toString())
// //                       );

// //                       setState(() {
// //                         destinationMarker = Marker(
// //                           point: destinationLatLng,
// //                           width: 60,
// //                           height: 60,
// //                           alignment: Alignment.topCenter,
// //                           child: const Icon(Icons.location_on, color: Colors.redAccent, size: 45),
// //                         );
// //                       });

// //                       getAndDrawRoute(destinationLatLng);
// //                       textEditingController.clear();
// //                       places.clear();
// //                       FocusScope.of(context).unfocus(); // إغلاق الكيبورد
// //                       setState(() {});
// //                     },
// //                     placesDetails: placesDetailsService,
// //                     itemCount: places.length,
// //                     places: places,
// //                   ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   void updateCurrentLocation() async {
// //     try {
// //       // استدعاء السيرفيس الخاصة بكِ والتي تطلب الإذن رسمياً
// //       var locationData = await locationService.getLocation();
      
// //       setMarker(locationData);
// //       setMyCameraPosition(locationData);
      
// //       log("Location precision: ${locationData.accuracy}");
// //     } catch (e) { 
// //       log("Location Error: ${e.toString()}");
// //       // في حالة الرفض، يمكن إظهار Snackbar للمستخدم هنا
// //     }
// //   }

// //   void setMyCameraPosition(loc.LocationData locationData) {
// //     mapController.move(
// //       LatLng(locationData.latitude!, locationData.longitude!),
// //       15.0,
// //     );
// //   }

// //   void setMarker(loc.LocationData locationData) {
// //     setState(() {
// //       myLocationMarker = Marker(
// //         point: LatLng(locationData.latitude!, locationData.longitude!),
// //         width: 40,
// //         height: 40,
// //         child: Container(
// //           decoration: BoxDecoration(
// //             color: Colors.blue.withOpacity(0.2),
// //             shape: BoxShape.circle,
// //             border: Border.all(color: Colors.white, width: 2),
// //           ),
// //           child: Center(
// //             child: Container(
// //               width: 15,
// //               height: 15,
// //               decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
// //             ),
// //           ),
// //         ),
// //       );
// //     });
// //   }
// // }


// // // import 'dart:developer';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter_map/flutter_map.dart';
// // // import 'package:latlong2/latlong.dart';
// // // import 'package:location/location.dart' as loc;
// // // import 'package:maps/models/places_autocomplete_model/places_autocomplete_model.dart';
// // // import 'package:maps/models/places_details_model/places_details_model.dart';
// // // import 'package:maps/utils/location_service.dart';
// // // import 'package:maps/utils/places_autocomplete_service.dart';
// // // import 'package:maps/utils/places_details_service.dart';
// // // import 'package:maps/utils/routes_service.dart';


// // // import 'package:maps/widgets/custom_text_field.dart';
// // // import 'package:maps/widgets/list_of_predictions.dart';

// // // class FlutterMapsView extends StatefulWidget {
// // //   const FlutterMapsView({super.key});

// // //   @override
// // //   State<FlutterMapsView> createState() => _FlutterMapsViewState();
// // // }

// // // class _FlutterMapsViewState extends State<FlutterMapsView> {
// // //   late PlacesAutocompleteService placesService;
// // //   late PlacesDetailsService placesDetailsService;
// // //   late TextEditingController textEditingController;
// // //   late LocationService locationService;
// // //   late MapController mapController;
  
// // //   Marker? myLocationMarker;
// // //   Marker? destinationMarker; 
// // //   List<PlacesAutocompleteModel> places = [];
// // //   List<LatLng> routePoints = [];

// // //   @override
// // //   void initState() {
// // //     textEditingController = TextEditingController();
// // //     placesService = PlacesAutocompleteService();
// // //     placesDetailsService = PlacesDetailsService();
// // //     fetchPredictions();
// // //     locationService = LocationService();
// // //     mapController = MapController();
// // //     updateCurrentLocation();
// // //     super.initState();
// // //   }

// // //   void fetchPredictions() {
// // //     textEditingController.addListener(() async {
// // //       if (textEditingController.text.isNotEmpty) {
// // //         var result = await placesService.getPredictions(
// // //           input: textEditingController.text,
// // //         );
// // //         places.clear();
// // //         places.addAll(result);
// // //         setState(() {});
// // //       } else {
// // //         places.clear();
// // //         setState(() {});
// // //       }
// // //     });
// // //   }

// // //   // دالة رسم الطريق مع تحسينات بصرية
// // //   void getAndDrawRoute(LatLng destination) async {
// // //     if (myLocationMarker == null) return;

// // //     try {
// // //       final points = await RouteService.fetchRoute(
// // //         myLocationMarker!.point, 
// // //         destination
// // //       );

// // //       if (points.isNotEmpty) {
// // //         setState(() {
// // //           routePoints = points;
// // //         });

// // //         // زووم ذكي ليشمل المسار بالكامل مع مساحة هوامش (Padding)
// // //         final bounds = LatLngBounds.fromPoints(routePoints);
// // //         mapController.fitCamera(
// // //           CameraFit.bounds(
// // //             bounds: bounds, 
// // //             padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 50),
// // //           ),
// // //         );
// // //       }
// // //     } catch (e) {
// // //       log("Error: $e");
// // //     }
// // //   }

// // //   @override
// // //   void dispose() {
// // //     textEditingController.dispose();
// // //     super.dispose();
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Stack(
// // //       children: [
// // //         FlutterMap(
// // //           mapController: mapController,
// // //           options: MapOptions(
// // //             initialCenter: LatLng(30.551196, 31.010724),
// // //             initialZoom: 12,
// // //           ),
// // //           children: [
// // //             // تغيير شكل الخريطة لنسخة "Light" أنظف واحترافية أكثر
// // //             TileLayer(
// // //               urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
// // //               subdomains: const ['a', 'b', 'c', 'd'],
// // //             ),
            
// // //             // --- تعديل شكل الراوت (Polyline) ليكون ناعماً ---
// // //             PolylineLayer(
// // //               polylines: [
// // //                 if (routePoints.isNotEmpty)
// // //                   Polyline(
// // //                     points: routePoints,
// // //                     color: const Color(0xFF2196F3), // أزرق خرائط جوجل
// // //                     strokeWidth: 5.0,
// // //                     strokeCap: StrokeCap.round, // زوايا دائرية في البداية والنهاية
// // //                     strokeJoin: StrokeJoin.round, // تنعيم الانعطافات
// // //                     // isOutline: true, // إضافة إطار للخط
// // //                     // outlineColor: const Color(0xFF1565C0), // إطار أزرق غامق
// // //                     borderStrokeWidth: 1.0,
// // //                   ),
// // //               ],
// // //             ),

// // //            MarkerLayer(
// // //   markers: [
// // //     // ماركر موقعي الحالي (شكل GPS حقيقي)
// // //     if (myLocationMarker != null)
// // //       Marker(
// // //         point: myLocationMarker!.point,
// // //         width: 40,
// // //         height: 40,
// // //         child: Container(
// // //           decoration: BoxDecoration(
// // //             color: Colors.blue.withOpacity(0.2),
// // //             shape: BoxShape.circle,
// // //             border: Border.all(color: Colors.white, width: 2),
// // //           ),
// // //           child: Center(
// // //             child: Container(
// // //               width: 15,
// // //               height: 15,
// // //               decoration: const BoxDecoration(
// // //                 color: Colors.blue,
// // //                 shape: BoxShape.circle,
// // //               ),
// // //             ),
// // //           ),
// // //         ),
// // //       ),

// // //     // ماركر الوجهة (دبوس أحمر احترافي)
// // //     if (destinationMarker != null)
// // //       Marker(
// // //         point: destinationMarker!.point,
// // //         width: 50,
// // //         height: 50,
// // //         alignment: Alignment.topCenter, // عشان السن يلمس الأرض بالظبط
// // //         child: const Icon(
// // //           Icons.location_on,
// // //           color: Colors.redAccent,
// // //           size: 50,
// // //           shadows: [
// // //             Shadow(color: Colors.black38, offset: Offset(0, 5), blurRadius: 10)
// // //           ],
// // //         ),
// // //       ),
// // //   ],
// // // ),
        
// // //         // شريط البحث
// // //         Positioned(
// // //           top: 40, // نزول قليل ليعطي شكلاً أفضل
// // //           left: 16,
// // //           right: 16,
// // //           child: Column(
// // //             children: [
// // //               Container(
// // //                 decoration: BoxDecoration(
// // //                   boxShadow: [
// // //                     BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)
// // //                   ],
// // //                 ),
// // //                 child: CustomTextField(textEditingController: textEditingController),
// // //               ),
// // //               const SizedBox(height: 8),
// // //               ListOfPredictions(
// // //                 onPlaceSelected: (PlacesDetailsModel placeDetails) {
// // //                   LatLng destinationLatLng = LatLng(
// // //                     double.parse(placeDetails.lat.toString()), 
// // //                     double.parse(placeDetails.lon.toString())
// // //                   );

// // //                   setState(() {
// // //                     // --- تعديل الماركر ليكون في مكانه الصحيح (Pin Alignment) ---
// // //                     destinationMarker = Marker(
// // //                       point: destinationLatLng,
// // //                       width: 60,
// // //                       height: 60,
// // //                       alignment: Alignment.topCenter, // السن المدبب يكون على الإحداثية
// // //                       child: const Icon(
// // //                         Icons.location_on, 
// // //                         color: Colors.redAccent, 
// // //                         size: 45,
// // //                         shadows: [Shadow(blurRadius: 10, color: Colors.black26)],
// // //                       ),
// // //                     );
// // //                   });

// // //                   getAndDrawRoute(destinationLatLng);
// // //                   textEditingController.clear();
// // //                   places.clear();
// // //                   setState(() {});
// // //                 },
// // //                 placesDetails: placesDetailsService,
// // //                 itemCount: places.length,
// // //                 places: places,
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ],
// // //     )]);
// // //   }

// // //   void updateCurrentLocation() async {
// // //     try {
// // //       var locationData = await locationService.getLocation();
// // //       setMarker(locationData);
// // //       setMyCameraPosition(locationData);
// // //     } catch (e) { log(e.toString()); }
// // //   }

// // //   void setMyCameraPosition(loc.LocationData locationData) {
// // //     mapController.move(
// // //       LatLng(locationData.latitude!, locationData.longitude!),
// // //       13.0,
// // //     );
// // //   }

// // //   void setMarker(loc.LocationData locationData) {
// // //     setState(() {
// // //       myLocationMarker = Marker(
// // //         point: LatLng(locationData.latitude!, locationData.longitude!),
// // //         width: 60,
// // //         height: 60,
// // //         alignment: Alignment.topCenter, // ضبط المحاذاة لموقعي أيضاً
// // //         child: const Icon(
// // //           Icons.person_pin_circle, 
// // //           color: Colors.blueAccent, 
// // //           size: 45,
// // //           shadows: [Shadow(blurRadius: 10, color: Colors.black26)],
// // //         ),
// // //       );
// // //     });
// // //   }
// // // }



// // // // import 'dart:developer';

// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter_map/flutter_map.dart';
// // // // import 'package:latlong2/latlong.dart';
// // // // import 'package:location/location.dart' as loc; // تجنب التعارض مع Geolocator
// // // // import 'package:maps/models/places_autocomplete_model/places_autocomplete_model.dart';
// // // // import 'package:maps/models/places_details_model/places_details_model.dart';
// // // // import 'package:maps/utils/location_service.dart';
// // // // import 'package:maps/utils/places_autocomplete_service.dart';
// // // // import 'package:maps/utils/places_details_service.dart';

// // // // import 'package:maps/utils/routes_service.dart';

// // // // import 'package:maps/widgets/custom_text_field.dart';
// // // // import 'package:maps/widgets/list_of_predictions.dart';

// // // // class FlutterMapsView extends StatefulWidget {
// // // //   const FlutterMapsView({super.key});

// // // //   @override
// // // //   State<FlutterMapsView> createState() => _FlutterMapsViewState();
// // // // }

// // // // class _FlutterMapsViewState extends State<FlutterMapsView> {
// // // //   late PlacesAutocompleteService placesService;
// // // //   late PlacesDetailsService placesDetailsService;
// // // //   late TextEditingController textEditingController;
// // // //   late LocationService locationService;
// // // //   late MapController mapController;
  
// // // //   Marker? myLocationMarker;
// // // //   Marker? destinationMarker; 
// // // //   List<PlacesAutocompleteModel> places = [];
// // // //   List<LatLng> routePoints = []; // النقاط اللي هنرسم بيها الخط

// // // //   @override
// // // //   void initState() {
// // // //     textEditingController = TextEditingController();
// // // //     placesService = PlacesAutocompleteService();
// // // //     placesDetailsService = PlacesDetailsService();
// // // //     fetchPredictions();
// // // //     locationService = LocationService();
// // // //     mapController = MapController();
// // // //     updateCurrentLocation();
// // // //     super.initState();
// // // //   }

// // // //   void fetchPredictions() {
// // // //     textEditingController.addListener(() async {
// // // //       if (textEditingController.text.isNotEmpty) {
// // // //         var result = await placesService.getPredictions(
// // // //           input: textEditingController.text,
// // // //         );
// // // //         places.clear();
// // // //         places.addAll(result);
// // // //         setState(() {});
// // // //       } else {
// // // //         places.clear();
// // // //         setState(() {});
// // // //       }
// // // //     });
// // // //   }

// // // //   // دالة رسم الطريق (باستخدام الطريقة التي طلبتِها - بدون فك تشفير)
// // // //   void getAndDrawRoute(LatLng destination) async {
// // // //     if (myLocationMarker == null) return;

// // // //     try {
// // // //       // استدعاء السيرفيس اللي بترجع List<LatLng> جاهزة
// // // //       final points = await RouteService.fetchRoute(
// // // //         myLocationMarker!.point, 
// // // //         destination
// // // //       );

// // // //       if (points.isNotEmpty) {
// // // //         setState(() {
// // // //           routePoints = points;
// // // //         });

// // // //         // تحريك الكاميرا لتشمل المسار بالكامل
// // // //         final bounds = LatLngBounds.fromPoints(routePoints);
// // // //         mapController.fitCamera(
// // // //           CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(70)),
// // // //         );
// // // //       }
// // // //     } catch (e) {
// // // //       log("Error drawing route: $e");
// // // //     }
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     textEditingController.dispose();
// // // //     super.dispose();
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Stack(
// // // //       children: [
// // // //         FlutterMap(
// // // //           mapController: mapController,
// // // //           options: MapOptions(
// // // //             initialCenter: LatLng(30.551196212478537, 31.010724633040052),
// // // //             initialZoom: 12,
// // // //           ),
// // // //           children: [
// // // //             TileLayer(
// // // //               urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
// // // //               userAgentPackageName: 'com.example.maps',
// // // //             ),
// // // //             // رسم المسار
// // // //             PolylineLayer(
// // // //               polylines: [
// // // //                 if (routePoints.isNotEmpty)
// // // //                   Polyline(
// // // //                     points: routePoints,
// // // //                     color: Colors.blueAccent,
// // // //                     strokeWidth: 6,
// // // //                   ),
// // // //               ],
// // // //             ),
// // // //             MarkerLayer(
// // // //               markers: [
// // // //                 if (myLocationMarker != null) myLocationMarker!,
// // // //                 if (destinationMarker != null) destinationMarker!,
// // // //               ],
// // // //             ),
// // // //           ],
// // // //         ),
// // // //         Positioned(
// // // //           top: 16,
// // // //           left: 16,
// // // //           right: 16,
// // // //           child: Column(
// // // //             children: [
// // // //               CustomTextField(textEditingController: textEditingController),
// // // //               const SizedBox(height: 16),
// // // //               ListOfPredictions(
// // // //                 onPlaceSelected: (PlacesDetailsModel placeDetails) {
// // // //                   log('Selected Place: ${placeDetails.lat}');
                  
// // // //                   LatLng destinationLatLng = LatLng(
// // // //                     double.parse(placeDetails.lat.toString()), 
// // // //                     double.parse(placeDetails.lon.toString())
// // // //                   );

// // // //                   setState(() {
// // // //                     // إنشاء ماركر الوجهة
// // // //                     destinationMarker = Marker(
// // // //                       point: destinationLatLng,
// // // //                       width: 60,
// // // //                       height: 60,
// // // //                       alignment: Alignment.bottomCenter,
// // // //                       child: const Icon(Icons.location_on, color: Colors.green, size: 45),
// // // //                     );
// // // //                   });

// // // //                   // طلب ورسم الطريق فور اختيار المكان
// // // //                   getAndDrawRoute(destinationLatLng);

// // // //                   textEditingController.clear();
// // // //                   places.clear();
// // // //                   setState(() {});
// // // //                 },
// // // //                 placesDetails: placesDetailsService,
// // // //                 itemCount: places.length,
// // // //                 places: places,
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //       ],
// // // //     );
// // // //   }

// // // //   void updateCurrentLocation() async {
// // // //     try {
// // // //       var locationData = await locationService.getLocation();
// // // //       setMyCameraPosition(locationData);
// // // //       setMarker(locationData);
// // // //     } catch (e) { /* ignore */ }
// // // //   }

// // // //   void setMyCameraPosition(loc.LocationData locationData) {
// // // //     mapController.move(
// // // //       LatLng(locationData.latitude!, locationData.longitude!),
// // // //       mapController.camera.zoom,
// // // //     );
// // // //   }

// // // //   void setMarker(loc.LocationData locationData) {
// // // //     setState(() {
// // // //       myLocationMarker = Marker(
// // // //         point: LatLng(locationData.latitude!, locationData.longitude!),
// // // //         width: 60,
// // // //         height: 60,
// // // //         alignment: Alignment.bottomCenter,
// // // //         child: const Icon(Icons.location_on, color: Colors.red, size: 40),
// // // //       );
// // // //     });
// // // //   }
// // // // }



// // // // import 'dart:developer';

// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter_map/flutter_map.dart';
// // // // import 'package:latlong2/latlong.dart';
// // // // import 'package:location/location.dart';
// // // // import 'package:maps/models/places_autocomplete_model/places_autocomplete_model.dart';
// // // // import 'package:maps/models/places_details_model/places_details_model.dart';
// // // // import 'package:maps/utils/location_service.dart';
// // // // import 'package:maps/utils/places_autocomplete_service.dart';
// // // // import 'package:maps/utils/places_details_service.dart';

// // // // import 'package:maps/widgets/custom_text_field.dart';
// // // // import 'package:maps/widgets/list_of_predictions.dart';

// // // // class FlutterMapsView extends StatefulWidget {
// // // //   const FlutterMapsView({super.key});

// // // //   @override
// // // //   State<FlutterMapsView> createState() => _FlutterMapsViewState();
// // // // }

// // // // class _FlutterMapsViewState extends State<FlutterMapsView> {
// // // //   late PlacesAutocompleteService placesService;
// // // //   late PlacesDetailsService placesDetailsService;
// // // //   late TextEditingController textEditingController;
// // // //   late LocationService locationService;
// // // //   late MapController mapController;
// // // //   Marker? myLocationMarker;
// // // //   List<PlacesAutocompleteModel>places=[];
// // // //   //  late Location location;

// // // //   @override
// // // //   void initState() {
// // // //     textEditingController = TextEditingController();
// // // //     placesService = PlacesAutocompleteService();
// // // //     placesDetailsService = PlacesDetailsService();
// // // //     fetchPredictions();
// // // //     // location = Location();
// // // //     locationService = LocationService();
// // // //     mapController = MapController();
// // // //     updateCurrentLocation();
// // // //     // updateMyLocation();
// // // //     super.initState();
// // // //   }

// // // //   void fetchPredictions() {
// // // //     textEditingController.addListener(() async {
// // // //       if (textEditingController.text.isNotEmpty) {
// // // //         var result = await placesService.getPredictions(
// // // //           input: textEditingController.text,
// // // //         );
// // // //         places.clear();
// // // //         places.addAll(result);
// // // //         setState(() {
          
// // // //         });
// // // //       }else{
// // // //         places.clear();
// // // //         setState(() {
          
// // // //         });
// // // //       }
// // // //       // log(textEditingController.text);
// // // //     });
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     textEditingController.dispose();
// // // //     // TODO: implement dispose
// // // //     super.dispose();
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Stack(
// // // //       children: [
// // // //         FlutterMap(
// // // //           mapController: mapController,
// // // //           options: MapOptions(
// // // //             // initialCameraFit: CameraFit.bounds(
// // // //             //   bounds: LatLngBounds.fromPoints([
// // // //             //     LatLng(30.582361879334343, 31.010437347372726),
// // // //             //     LatLng(30.53496088922579, 31.00533090113106),
// // // //             //   ]),
// // // //             // ),
// // // //             initialCenter: LatLng(30.551196212478537, 31.010724633040052),
// // // //             initialZoom: 12,
// // // //           ),
// // // //           children: [
// // // //             TileLayer(
// // // //               urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
// // // //               userAgentPackageName: 'com.example.maps',
// // // //             ),
// // // //             MarkerLayer(
// // // //               markers: [
// // // //                 if (myLocationMarker != null)
// // // //                   myLocationMarker!, // ضيفيه لو موجود بس
// // // //                 // ...staticPlaces, // لو عندك أماكن تانية ضيفيها هنا
// // // //               ],
// // // //             ),
// // // //           ],
// // // //         ),
// // // //         Positioned(
// // // //           top: 16,
// // // //           left: 16,
// // // //           right: 16,
// // // //           child: Column(
// // // //             children: [
// // // //               CustomTextField(textEditingController: textEditingController),
// // // //               SizedBox(height: 16,),
// // // //               ListOfPredictions(
// // // //                 onPlaceSelected: (PlacesDetailsModel placeDetails) {
// // // //                   // هنا هتتعامل مع المكان اللي اتحدد
// // // //                   log('Selected Place: ${placeDetails.lat}');
// // // //             textEditingController.clear();
// // // //             places.clear();
// // // //             setState(() {});

// // // //                 },
// // // //                 placesDetails: placesDetailsService,
// // // //                 itemCount: places.length,places: places,),
// // // //             ],
// // // //           ),
// // // //         ),

// // // //         // Positioned(
// // // //         //   bottom: 16,
// // // //         //   right: 16,
// // // //         //   child: FloatingActionButton(
// // // //         //     child: Icon(Icons.add),
// // // //         //     onPressed: () {
// // // //         //       mapController.move(

// // // //         //         LatLng(30.40980795900272, 31.017127504150995),
// // // //         //         12,
// // // //         //       );
// // // //         //     },
// // // //         //   ),
// // // //         // ),
// // // //       ],
// // // //     );
// // // //   }

// // // //   void updateCurrentLocation() async {
// // // //     try {
// // // //       var locationData = await locationService.getLocation();
// // // //       setMyCameraPosition(locationData);
// // // //       setMarker(locationData);
// // // //     } on LocationServiceException catch (e) {
// // // //       // TODO
// // // //     } on LocationPermissionException catch (e) {
// // // //       // TODO
// // // //     } catch (e) {}
// // // //   }
// // // //   // void updateMyLocation() async {
// // // //   //   await locationService.checkAndRequestLocationService();
// // // //   //   var hasPermission = await locationService
// // // //   //       .checkAndRequestLocationPermission();
// // // //   //   if (hasPermission) {
// // // //   //     locationService.getRealTimeLocationData((locationData) {
// // // //   //       if (locationData.latitude != null && locationData.longitude != null) {
// // // //   //         setMarker(locationData);

// // // //   //         // تحريك الكاميرا
// // // //   //         setMyCameraPosition(locationData);
// // // //   //       }
// // // //   //     });
// // // //   //   }
// // // //   // }

// // // //   void setMyCameraPosition(LocationData locationData) {
// // // //     mapController.move(
// // // //       LatLng(locationData.latitude!, locationData.longitude!),
// // // //       mapController.camera.zoom,
// // // //     );
// // // //   }

// // // //   void setMarker(LocationData locationData) {
// // // //     setState(() {
// // // //       myLocationMarker = Marker(
// // // //         point: LatLng(locationData.latitude!, locationData.longitude!),
// // // //         width: 60,
// // // //         height: 60,
// // // //         alignment: Alignment.bottomCenter,
// // // //         child: Icon(Icons.location_on, color: Colors.red, size: 40),
// // // //       );
// // // //     });
// // // //   }
// // // // }

// // // // // void getLocationData() {
// // // // //   location.changeSettings(distanceFilter: 2);
// // // // //   location.onLocationChanged.listen((locationData) {
// // // // //     if (locationData.latitude != null && locationData.longitude != null) {
// // // // //       setState(() {
// // // // //         // تحديث الماركر الوحيد بدل عمل add
// // // // //         myLocationMarker = Marker(
// // // // //           point: LatLng(locationData.latitude!, locationData.longitude!),
// // // // //           width: 60,
// // // // //           height: 60,
// // // // //           alignment: Alignment.bottomCenter,
// // // // //           child: Icon(Icons.location_on, color: Colors.red, size: 40),
// // // // //         );
// // // // //       });

// // // // //       // تحريك الكاميرا
// // // // //       mapController.move(
// // // // //         LatLng(locationData.latitude!, locationData.longitude!),
// // // // //         mapController
// // // // //             .camera
// // // // //             .zoom, // استخدمي الزووم الحالي بدل ما يرجع لـ 12 كل شوية
// // // // //       );
// // // // //     }
// // // // //   });
// // // // // }

// // // // // world view zomm level from 0 to 3
// // // // // country view zomm level from 4 to 6
// // // // // city view from 10 to 12
// // // // // strret view from 13 to 17
// // // // // building view  from 18 to 20
