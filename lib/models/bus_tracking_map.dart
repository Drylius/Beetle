
// lib/widgets/bus_tracking_map.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

const String geoapifyApiKey = "b0b1fb9ba3bc4707abdf5a59aea207be";

/// HARD-CODED CAMPUS COORDINATES
const LatLng kAlamSuteraCampus = LatLng(-6.222609, 106.649168);
const LatLng kAnggrekCampus    = LatLng(-6.2017585, 106.7796798);

/// Optional: fallback straight line if routing API fails
List<LatLng> getFallbackRoutePolyline(String routeName) {
  final name = routeName.toLowerCase();

  final alamIndex = name.indexOf("alam sutera");
  final anggrekIndex = name.indexOf("anggrek");

  if (alamIndex == -1 || anggrekIndex == -1) return [];

  if (alamIndex < anggrekIndex) {
    // Alam Sutera → Anggrek
    return [
      kAlamSuteraCampus,
      kAnggrekCampus,
    ];
  } else {
    // Anggrek → Alam Sutera
    return [
      kAnggrekCampus,
      kAlamSuteraCampus,
    ];
  }
}


/// Map widget: handles routing, tiles, and live tracking
class BusTrackingMap extends StatefulWidget {
  final String busId;
  final String routeName;

  const BusTrackingMap({
    super.key,
    required this.busId,
    required this.routeName,
  });

  @override
  State<BusTrackingMap> createState() => _BusTrackingMapState();
}

class _BusTrackingMapState extends State<BusTrackingMap> {
  final MapController _mapController = MapController();

  // Default center (near BINUS)
  LatLng _fallbackCenter = const LatLng(-6.221, 106.652);

  List<LatLng>? _routePoints;     // from Geoapify routing
  bool _isRouteLoading = false;
  String? _routeError;

  @override
  void initState() {
    super.initState();
    _loadRouteFromGeoapify();
  }

  /// Determine start & end based on route name
  (LatLng, LatLng)? _getEndpointsForRoute(String routeName) {
    final name = routeName.toLowerCase();

    final alamIndex = name.indexOf("alam sutera");
    final anggrekIndex = name.indexOf("anggrek");

    if (alamIndex == -1 || anggrekIndex == -1) {
      return null; // one of them not found
    }

    if (alamIndex < anggrekIndex) {
      // Alam Sutera → Anggrek
      return (kAlamSuteraCampus, kAnggrekCampus);
    } else {
      // Anggrek → Alam Sutera
      return (kAnggrekCampus, kAlamSuteraCampus);
    }
  }


  /// Call Geoapify Routing API to get polyline points
  Future<List<LatLng>> _fetchGeoapifyRoute(
    LatLng start,
    LatLng end,
  ) async {
    final url = Uri.parse(
      "https://api.geoapify.com/v1/routing"
      "?waypoints=${start.latitude},${start.longitude}|${end.latitude},${end.longitude}"
      "&mode=drive"
      "&apiKey=$geoapifyApiKey",
    );

    final res = await http.get(url);

    if (res.statusCode != 200) {
      throw Exception("Routing API failed: ${res.statusCode}");
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final features = body["features"] as List<dynamic>;
    if (features.isEmpty) {
      throw Exception("No route found");
    }

    final geometry = features[0]["geometry"] as Map<String, dynamic>;
    final coords = geometry["coordinates"] as List<dynamic>;
    // MultiLineString: [ [ [lon, lat], ... ], ... ]

    final List<LatLng> points = [];
    for (final line in coords) {
      for (final pt in (line as List<dynamic>)) {
        final lon = (pt[0] as num).toDouble();
        final lat = (pt[1] as num).toDouble();
        points.add(LatLng(lat, lon)); // (lat, lon)
      }
    }

    return points;
  }

  /// Loader: called on initState, fill _routePoints
  Future<void> _loadRouteFromGeoapify() async {
    final endpoints = _getEndpointsForRoute(widget.routeName);
    if (endpoints == null) {
      return;
    }

    setState(() {
      _isRouteLoading = true;
      _routeError = null;
    });

    try {
      final points = await _fetchGeoapifyRoute(endpoints.$1, endpoints.$2);
      setState(() {
        _routePoints = points;
        _isRouteLoading = false;
      });
    } catch (e) {
      setState(() {
        _routeError = e.toString();
        _isRouteLoading = false;
        _routePoints = getFallbackRoutePolyline(widget.routeName);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection("buses")
          .doc(widget.busId)
          .snapshots(),
      builder: (context, snapshot) {
        // Use routing result if available, otherwise fallback
        final routePoints =
            _routePoints ?? getFallbackRoutePolyline(widget.routeName);

        // CASE 1: still loading Firestore
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // CASE 2: no bus doc yet → show route + start/end, no bus marker
        if (!snapshot.hasData || !snapshot.data!.exists) {
          final center =
              routePoints.isNotEmpty ? routePoints.first : _fallbackCenter;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _mapController.move(center, 14);
          });

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 14,
            ),
            children: [
              // Geoapify tiles
              TileLayer(
                urlTemplate:
                    "https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}.png?apiKey=$geoapifyApiKey",
                userAgentPackageName: "com.beetle.app",
              ),

              // Route polyline
              if (routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 4,
                      color: Colors.blue,
                    ),
                  ],
                ),

              // Start & end markers
              if (routePoints.isNotEmpty)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: routePoints.first,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.green,
                        size: 35,
                      ),
                    ),
                    Marker(
                      point: routePoints.last,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.flag,
                        color: Colors.blue,
                        size: 35,
                      ),
                    ),
                  ],
                ),
            ],
          );
        }

        // CASE 3: bus doc exists → show route + bus marker
        final data = snapshot.data!.data();
        if (data == null) {
          return const Center(
            child: Text(
              "Bus location unavailable",
              style: TextStyle(fontSize: 15),
            ),
          );
        }

        final double lat =
            (data["lat"] as num?)?.toDouble() ?? _fallbackCenter.latitude;
        final double lng =
            (data["lng"] as num?)?.toDouble() ?? _fallbackCenter.longitude;

        final busPos = LatLng(lat, lng);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(busPos, 15);
        });

        return FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: busPos,
            initialZoom: 15,
          ),
          children: [
            // 1. Geoapify tiles
            TileLayer(
              urlTemplate:
                  "https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}.png?apiKey=$geoapifyApiKey",
              userAgentPackageName: "com.beetle.app",
            ),

            // 2. Route polyline
            if (routePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    strokeWidth: 4,
                    color: Colors.blue,
                  ),
                ],
              ),

            // 3. Start + end markers
            if (routePoints.isNotEmpty)
              MarkerLayer(
                markers: [
                  Marker(
                    point: routePoints.first,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 35,
                    ),
                  ),
                  Marker(
                    point: routePoints.last,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.flag,
                      color: Colors.blue,
                      size: 35,
                    ),
                  ),
                ],
              ),

            // 4. Bus marker
            MarkerLayer(
              markers: [
                Marker(
                  point: busPos,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.directions_bus,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
