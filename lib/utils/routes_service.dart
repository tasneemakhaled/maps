import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class RouteService {
  /// جلب موقع الجهاز الحالي
  static Future<LatLng?> getCurrentLocation(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showMsg(context, 'Please enable location services');
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showMsg(context, 'Location permission denied');
        return null;
      }
    }

    final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    return LatLng(pos.latitude, pos.longitude);
  }

  /// تحويل إحداثيات [start] و [end] إلى مسار مرسوم (بدون فك تشفير)
  static Future<List<LatLng>> fetchRoute(LatLng start, LatLng end) async {
    final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // هنا البيانات بتيجي قائمة إحداثيات جاهزة بفضل geometries=geojson
      final coords = data['routes'][0]['geometry']['coordinates'] as List<dynamic>;
      return coords.map((c) => LatLng(
      (c[1] as num).toDouble(), 
      (c[0] as num).toDouble(),
    )).toList();
    }
    return [];
  }

  /// تحويل اسم المكان لإحداثيات
  static Future<LatLng?> getCoordinatesFromPlace(String place) async {
    if (place.trim().isEmpty) return null;
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$place&format=json&addressdetails=1');

    final response = await http.get(url, headers: {'User-Agent': 'FlutterApp'});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        return LatLng(lat, lon);
      }
    }
    return null;
  }

  /// تحويل الإحداثيات لاسم مكان
  static Future<String> getPlaceName(double lat, double lon) async {
    try {
      final url = Uri.parse(
        "https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lon&addressdetails=1",
      );
      final response = await http.get(url, headers: {"User-Agent": "FlutterApp"});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data["address"] ?? {};
        final place = address["road"] ?? address["suburb"] ?? "Unknown place";
        final city = address["city"] ?? address["state"] ?? "Unknown city";
        return "$place, $city";
      }
    } catch (e) { /* ignore */ }
    return "Unknown location";
  }

  static void _showMsg(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
// import 'package:http/http.dart' as http;
// import 'package:maps/models/routes_model.dart';


// class RoutesService {
//   // الرابط الأساسي لخدمة الـ Routing
//   static const String _baseUrl = "http://router.project-osrm.org/route/v1/driving";

//   /// إرسال قائمة نقاط "lon,lat" والحصول على المسار
//   Future<RoutesResponse?> getFullRoute(List<String> points) async {
//     final String coordinatesPath = points.join(';');
    
//     // ملاحظة: overview=full و geometries=polyline ضرورية جداً للرسم
//     final url = Uri.parse('$_baseUrl/$coordinatesPath?overview=full&geometries=polyline');

//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         return RoutesResponse.fromRawJson(response.body);
//       } else {
//         print("سيرفر OSRM أعاد خطأ: ${response.statusCode}");
//         return null;
//       }
//     } catch (e) {
//       print("خطأ في الاتصال بالإنترنت: $e");
//       return null;
//     }
//   }
// }