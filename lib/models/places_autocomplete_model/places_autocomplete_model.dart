import 'feature.dart';

class PlacesAutocompleteModel {
  String? type;
  List<Feature>? features;

  PlacesAutocompleteModel({this.type, this.features});

  factory PlacesAutocompleteModel.fromJson(Map<String, dynamic> json) {
    return PlacesAutocompleteModel(
      type: json['type'] as String?,
      features: (json['features'] as List<dynamic>?)
          ?.map((e) => Feature.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'features': features?.map((e) => e.toJson()).toList(),
  };
}
