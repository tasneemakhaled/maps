import 'package:flutter/material.dart';
import 'package:maps/widgets/custom_flutter_maps.dart';

class TestFlutterMaps extends StatelessWidget {
  const TestFlutterMaps({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: CustomFlutterMaps());
  }
}

//inquire about location service (is it enabled in device to access location or not)
//request permission
//get location
//display
