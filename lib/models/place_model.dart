import 'package:latlong2/latlong.dart';

class PlaceModel {
  final int id;
  final String name;
  final LatLng latLng;

  PlaceModel({required this.id, required this.name, required this.latLng});
}

List<PlaceModel> places = [
  PlaceModel(
    id: 1,
    name: 'كريب طه',
    latLng: LatLng(30.609569741092603, 30.98700145227266),
  ),
  PlaceModel(
    id: 2,
    name: 'مول سعيد الشباسي للجهزة الكهرباءية',
    latLng: LatLng(30.611007481825805, 30.984189582725296),
  ),
  PlaceModel(
    id: 3,
    name: 'مستشفي الشروق التخصصي الجديدة',
    latLng: LatLng(30.612420627662015, 30.986823959756872),
  ),
];
