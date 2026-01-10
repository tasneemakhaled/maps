// lib/models/places_autocomplete_model/places_autocomplete_model.dart

class PlacesAutocompleteModel {
  final int? placeId;
  final String? name;
  final String? displayName;
  final String? lat;
  final String? lon;

  PlacesAutocompleteModel({
    this.placeId,
    this.name,
    this.displayName,
    this.lat,
    this.lon,
  });

  factory PlacesAutocompleteModel.fromJson(Map<String, dynamic> json) {
    return PlacesAutocompleteModel(
      placeId: json['place_id'],
      name: json['name'],
      displayName: json['display_name'],
      lat: json['lat'],
      lon: json['lon'],
    );
  }
}