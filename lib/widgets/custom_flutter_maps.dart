import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CustomFlutterMaps extends StatefulWidget {
  const CustomFlutterMaps({super.key});

  @override
  State<CustomFlutterMaps> createState() => _CustomFlutterMapsState();
}

class _CustomFlutterMapsState extends State<CustomFlutterMaps> {
  MapController mapController = MapController();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            // initialCameraFit: CameraFit.bounds(
            //   bounds: LatLngBounds.fromPoints([
            //     LatLng(30.582361879334343, 31.010437347372726),
            //     LatLng(30.53496088922579, 31.00533090113106),
            //   ]),
            // ),
            initialCenter: LatLng(30.551196212478537, 31.010724633040052),
            initialZoom: 10,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.maps',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(30.551196212478537, 31.010724633040052),
                  alignment: Alignment.bottomCenter,
                  child: Icon(Icons.location_on, color: Colors.red, size: 40),
                ),
              ],
            ),
          ],
        ),
        // Positioned(
        //   bottom: 16,
        //   right: 16,
        //   child: FloatingActionButton(
        //     child: Icon(Icons.add),
        //     onPressed: () {
        //       mapController.move(

        //         LatLng(30.40980795900272, 31.017127504150995),
        //         12,
        //       );
        //     },
        //   ),
        // ),
      ],
    );
  }
}



// world view zomm level from 0 to 3
// country view zomm level from 4 to 6
// city view from 10 to 12
// strret view from 13 to 17
// building view  from 18 to 20