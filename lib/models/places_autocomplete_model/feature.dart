import 'geometry.dart';
import 'properties.dart';

class Feature {
  String? type;
  Properties? properties;
  Geometry? geometry;

  Feature({this.type, this.properties, this.geometry});

  factory Feature.fromJson(Map<String, dynamic> json) => Feature(
    type: json['type'] as String?,
    properties: json['properties'] == null
        ? null
        : Properties.fromJson(json['properties'] as Map<String, dynamic>),
    geometry: json['geometry'] == null
        ? null
        : Geometry.fromJson(json['geometry'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    'type': type,
    'properties': properties?.toJson(),
    'geometry': geometry?.toJson(),
  };
}
