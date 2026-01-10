import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:maps/models/places_autocomplete_model/places_autocomplete_model.dart';

class PlacesAutocompleteService {
  Future<List<PlacesAutocompleteModel>> getPredictions({required String input}) async {
    // 1. لازم نستخدم Uri.https عشان نبعت الـ query parameters بشكل صحيح وآمن
    final url = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': input,
      'format': 'json',
      'limit': '10',
    });

    // 2. الـ User-Agent ده ضروري جداً عشان Nominatim ميعملش Block للطلب
    final response = await http.get(url, headers: {
      'User-Agent': "com.example.maps", // اكتب اسم تطبيقك هنا
    });

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<PlacesAutocompleteModel> places = [];

      for (var item in data) {
        if (item is Map<String, dynamic> && item.isNotEmpty) {
          places.add(PlacesAutocompleteModel.fromJson(item));
        }
      }
      return places;
    } else {
      // طبعنا الـ Status Code هنا عشان لو في مشكلة تانية تعرف سببها من الـ Debug Console
      print('Error Status Code: ${response.statusCode}');
      print('Error Body: ${response.body}');
      throw Exception('Failed to load predictions');
    }
  }
}