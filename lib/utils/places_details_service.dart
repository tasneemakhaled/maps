import 'dart:convert' show jsonDecode;
import 'package:http/http.dart' as http;
import 'package:maps/models/places_details_model/places_details_model.dart';

class PlacesDetailsService {
  // الرابط الأساسي للبحث (الذي استخدمتيه)
  static const String _searchUrl = 'https://nominatim.openstreetmap.org/search';
  // الرابط الأساسي للتفاصيل (الجديد)
  static const String _detailsUrl = 'https://nominatim.openstreetmap.org/details';

  // --- ميثود البحث عن أماكن (التي لديكِ بالفعل) ---
  Future<List<PlacesDetailsModel>> searchPlaces(String query) async {
    try {
      final Uri url = Uri.parse('$_searchUrl?q=$query&format=json&addressdetails=1');
      final response = await http.get(
        url,
        headers: {
          'User-Agent': "com.example.maps",
          'Accept-Language': 'ar',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => PlacesDetailsModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error Exception: $e');
      return [];
    }
  }

  // --- الميثود الجديدة: جلب تفاصيل مكان واحد فقط بالـ ID ---
  Future<PlacesDetailsModel?> getPlaceDetails(String lat, String lon) async {
    try {
      // بناء الرابط: نستخدم details ونمرر place_id ونحدد الصيغة json
      final Uri url = Uri.parse(
         'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': "com.example.maps",
          'Accept-Language': 'ar',
        },
      );

      if (response.statusCode == 200) {
        // انتبهي: رد التفاصيل يكون كائن واحد (Map) وليس قائمة (List)
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        // تحويل البيانات باستخدام الموديل الخاص بكِ
        return PlacesDetailsModel.fromJson(data);
      } else {
        print('Server Error in Details: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception in getPlaceDetails: $e');
      return null;
    }
  }
}