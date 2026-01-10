import 'package:flutter/material.dart';
import 'package:maps/views/flutter_maps_view.dart';

class TestFlutterMaps extends StatelessWidget {
  const TestFlutterMaps({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(child: FlutterMapsView()),
    );
  }
}

//inquire about location service (is it enabled in device to access location or not)
//request permission
//get location
//display
