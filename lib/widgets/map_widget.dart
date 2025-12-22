import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

//Map Widget/Display

class MapsWidget extends StatefulWidget {
  const MapsWidget({super.key});
  @override
  State<MapsWidget> createState() => _MapsWidgetState();
}

class _MapsWidgetState extends State<MapsWidget> {
  // 1. Set the initial camera position
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(37.773972, -122.431297),
    zoom: 11.5,
  );

  @override
  Widget build(BuildContext context) {
    // 2. Return the GoogleMap widget
    return GoogleMap(
      initialCameraPosition: _initialCameraPosition,
      zoomControlsEnabled: false,
      // 3. Define the markers to display on the map
      markers: {
        Marker(
          markerId: MarkerId('marker1'),
          position: LatLng(37.773972, -122.431297),
          infoWindow: InfoWindow(title: 'Point A'),
        ),
        Marker(
          markerId: MarkerId('marker2'),
          position: LatLng(37.789853, -122.394203),
          infoWindow: InfoWindow(title: 'Point B'),
        ),
      },
    );
  }
}