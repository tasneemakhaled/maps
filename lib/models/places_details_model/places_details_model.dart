import 'address.dart';

class PlacesDetailsModel {
  int? placeId;
  String? licence;
  String? osmType;
  int? osmId;
  String? lat;
  String? lon;
  String? placesDetailsModelClass;
  String? type;
  int? placeRank;
  double? importance;
  String? addresstype;
  String? name;
  String? displayName;
  Address? address;
  List<dynamic>? boundingbox;

  PlacesDetailsModel({
    this.placeId,
    this.licence,
    this.osmType,
    this.osmId,
    this.lat,
    this.lon,
    this.placesDetailsModelClass,
    this.type,
    this.placeRank,
    this.importance,
    this.addresstype,
    this.name,
    this.displayName,
    this.address,
    this.boundingbox,
  });

  factory PlacesDetailsModel.fromJson(Map<String, dynamic> json) {
    return PlacesDetailsModel(
      placeId: json['place_id'] as int?,
      licence: json['licence'] as String?,
      osmType: json['osm_type'] as String?,
      osmId: json['osm_id'] as int?,
      lat: json['lat'] as String?,
      lon: json['lon'] as String?,
      placesDetailsModelClass: json['class'] as String?,
      type: json['type'] as String?,
      placeRank: json['place_rank'] as int?,
      importance: (json['importance'] as num?)?.toDouble(),
      addresstype: json['addresstype'] as String?,
      name: json['name'] as String?,
      displayName: json['display_name'] as String?,
      address: json['address'] == null
          ? null
          : Address.fromJson(json['address'] as Map<String, dynamic>),
      boundingbox: json['boundingbox'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'place_id': placeId,
    'licence': licence,
    'osm_type': osmType,
    'osm_id': osmId,
    'lat': lat,
    'lon': lon,
    'class': placesDetailsModelClass,
    'type': type,
    'place_rank': placeRank,
    'importance': importance,
    'addresstype': addresstype,
    'name': name,
    'display_name': displayName,
    'address': address?.toJson(),
    'boundingbox': boundingbox,
  };
}
