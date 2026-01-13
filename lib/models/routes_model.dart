import 'dart:convert';

class RoutesResponse {
  final String code;
  final List<RouteData> routes;

  RoutesResponse({required this.code, required this.routes});

  factory RoutesResponse.fromRawJson(String str) => RoutesResponse.fromJson(json.decode(str));

  factory RoutesResponse.fromJson(Map<String, dynamic> json) => RoutesResponse(
        code: json["code"] ?? "",
        routes: json["routes"] == null
            ? []
            : List<RouteData>.from(json["routes"].map((x) => RouteData.fromJson(x))),
      );
}

class RouteData {
  final double distance;
  final double duration;
  final String? geometry; // النص المشفر للرسم

  RouteData({
    required this.distance,
    required this.duration,
    this.geometry,
  });

  factory RouteData.fromJson(Map<String, dynamic> json) => RouteData(
        distance: (json["distance"] as num).toDouble(),
        duration: (json["duration"] as num).toDouble(),
        geometry: json["geometry"],
      );
}