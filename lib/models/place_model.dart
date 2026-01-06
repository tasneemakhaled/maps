import 'package:latlong2/latlong.dart';

class PlaceModel {
  final int id;
  final String name;
  final LatLng latLng;

  PlaceModel({required this.id, required this.name, required this.latLng});
}

List<PlaceModel> places = [
  PlaceModel(
    id: 0,
    name: 'البتانون',
    latLng: LatLng(30.610106772213705, 30.987230289423874),
  ),
  PlaceModel(
    id: 1,
    name: 'تلا',
    latLng: LatLng(30.680173906484594, 30.944092404172185),
  ),
  PlaceModel(
    id: 2,
    name: 'كمشيش',
    latLng: LatLng(30.612263822689524, 30.941917039071686),
  ),
  PlaceModel(
    id: 3,
    name: 'بخاتي',
    latLng: LatLng(30.584031040826122, 30.95948102077),
  ),
];
