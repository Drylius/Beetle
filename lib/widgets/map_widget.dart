import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

//Map Widget/Display

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});
  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late GoogleMapController mapController;

  // Coordinates for campuses (Anggrek & Alam Sutera)
  static const LatLng _anggrekLocation = LatLng(-6.201756, 106.782160);
  static const LatLng _alsutLocation = LatLng(-6.223167, 106.649500);

  // 1. Set the initial camera position
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(-6.212, 106.715), // Centered between the two
    zoom: 12.0,
  );

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Track Bus Location"),
        backgroundColor: Colors.teal,
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: _initialCameraPosition,
        zoomControlsEnabled: true,
        markers: {
          const Marker(
            markerId: MarkerId('anggrek'),
            position: _anggrekLocation,
            infoWindow: InfoWindow(title: 'Anggrek Campus'),
          ),
          const Marker(
            markerId: MarkerId('alsut'),
            position: _alsutLocation,
            infoWindow: InfoWindow(title: 'Alam Sutera Campus'),
          ),
          Marker(
            markerId: const MarkerId('bus_location'),
            position: const LatLng(-6.215, 106.720),
            infoWindow: const InfoWindow(title: 'Shuttle Bus'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        },
      ),
    );
  }
}