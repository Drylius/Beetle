import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class DriverGpsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<Position>? _positionStream;

  /// Call this when driver starts driving
  Future<void> startTracking({
    required String busId,
  }) async {
    // 1. Check & request permission
    final permission = await _checkPermission();
    if (!permission) {
      throw Exception("Location permission not granted");
    }

    // 2. Start GPS stream
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // meters
      ),
    ).listen((position) {
      _sendLocationToFirestore(
        busId: busId,
        position: position,
      );
    });
  }

  /// Stop tracking (call when driver ends shift)
  Future<void> stopTracking() async {
    await _positionStream?.cancel();
    _positionStream = null;
  }

  /// Upload GPS to Firestore
  Future<void> _sendLocationToFirestore({
    required String busId,
    required Position position,
  }) async {
    await _firestore.collection("buses").doc(busId).set({
      "lat": position.latitude,
      "lng": position.longitude,
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Permission handling
  Future<bool> _checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }
}
