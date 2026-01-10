import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:maps/models/places_autocomplete_model/places_autocomplete_model.dart';

class PlacesService {
    Future<List<PlacesAutocompleteModel>> getPredictions({required String input})async{
    var response =await http.get(Uri.parse('https://photon.komoot.io/api/?q=$input')) ;
    if (response.statusCode==200){
        var data =jsonDecode(response.body)['features'];
        List<PlacesAutocompleteModel>places=[];
        for (var item in data) {
          places.add(PlacesAutocompleteModel.fromJson(item));
        }
        return places;
    }
    else{
        throw Exception();
    }
    }
}