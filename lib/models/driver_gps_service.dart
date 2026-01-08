import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class DriverGpsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<Position>? _positionStream;

  /// Call this when driver starts driving
  Future<void> startTracking({required String busId}) async {
    final permission = await _checkPermission();
    if (!permission) throw Exception("Location permission not granted");

    // 1. GET INITIAL POSITION IMMEDIATELY
    try {
      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      // Send it to Firestore right away
      await _sendLocationToFirestore(busId: busId, position: currentPosition);
      debugPrint("Initial location sent to Firestore");
    } catch (e) {
      debugPrint("Could not get initial location: $e");
    }

    // 2. CONFIGURE SETTINGS
    final AndroidSettings androidSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0, // Set to 0 for testing so every movement counts
      intervalDuration: const Duration(seconds: 5),
      foregroundNotificationConfig: ForegroundNotificationConfig(
        notificationTitle: "Beetle Trip Active",
        notificationText: "Tracking location for Bus: $busId",
        notificationIcon: AndroidResource(name: 'ic_launcher'),
        enableWakeLock: true,
      ),
    );

    // 3. START STREAM (Updates only on movement)
    _positionStream =
        Geolocator.getPositionStream(locationSettings: androidSettings).listen((
          position,
        ) {
          _sendLocationToFirestore(busId: busId, position: position);
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
    if (!serviceEnabled) {
      // Optionally: show a snackbar telling the user to turn on GPS
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    // 1. Handle Denied Status
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    // 2. Handle Denied Forever
    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    // 3. Upgrade to "Always" for Background Tracking
    // If we only have 'whileInUse', we need to ask for 'always'
    // so the foreground service doesn't get killed.
    if (permission == LocationPermission.whileInUse) {
      // This will take the user to a settings screen on Android 11+
      permission = await Geolocator.requestPermission();

      if (permission != LocationPermission.always) {
        // The driver said 'No' to background access.
        // You can still track, but it might stop when they minimize the app.
        debugPrint(
          "Background location not granted. Only Foreground tracking available.",
        );
      }
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }
}
