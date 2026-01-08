// lib/screens/bus_tracking_screen.dart
import 'package:flutter/material.dart';
import 'package:beetle/models/bus_tracking_map.dart'; // 👈 adjust path if needed

class BusTrackingScreen extends StatelessWidget {
  final String busId;
  final String routeName;      // ex: "Alam Sutera → Anggrek"
  final String departureTime;  // ex: "11:30"
  final String driverName;     // ex: "Budi"
  final String busName;        // ex: "Shuttle 01"
  final String status;         // "standby", "on the way", "completed"

  const BusTrackingScreen({
    super.key,
    required this.busId,
    required this.routeName,
    required this.departureTime,
    required this.driverName,
    required this.busName,
    required this.status,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "standby":
        return Colors.blue;
      case "on the way":
        return Colors.orange;
      case "completed":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          "Live Tracking",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // ===== TOP INFO CARD (same design as your schedule cards) =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                    color: Colors.black.withOpacity(0.08),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ROUTE NAME
                    Text(
                      routeName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // DEPARTURE TIME
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 20,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          departureTime,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // DRIVER + BUS + STATUS CHIP ROW
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Driver
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 20,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              driverName,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),

                        // Bus name
                        Row(
                          children: [
                            Icon(
                              Icons.directions_bus,
                              size: 20,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              busName,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),

                        // STATUS CHIP
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(status).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 13,
                              color: _statusColor(status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ===== MAP AREA (SEPARATE WIDGET) =====
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                      color: Colors.black.withOpacity(0.08),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: BusTrackingMap(
                  busId: busId,
                  routeName: routeName,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
