import 'package:flutter/material.dart';
import 'package:beetle/controllers/load_registrations.dart';
import 'package:beetle/models/bus_tracking_map.dart';
import 'package:beetle/models/driver_gps_service.dart';
import 'package:beetle/models/shuttle_slot_model.dart';

class DriverTripTrackingScreen extends StatefulWidget {
  final ShuttleSlot slot;

  const DriverTripTrackingScreen({
    super.key,
    required this.slot,
  });

  @override
  State<DriverTripTrackingScreen> createState() =>
      _DriverTripTrackingScreenState();
}

class _DriverTripTrackingScreenState extends State<DriverTripTrackingScreen> {
  final DriverGpsService _gpsService = DriverGpsService();
  final LoadRegistrations _loader = LoadRegistrations();

  bool _starting = true;
  bool _gpsActive = false;
  bool _completing = false;

  @override
  void initState() {
    super.initState();
    _startGps();
  }

  @override
  void dispose() {
    _gpsService.stopTracking(); // safety: stop when leaving screen
    super.dispose();
  }

  Future<void> _startGps() async {
    final busId = widget.slot.bus;

    if (busId == null || busId.isEmpty) {
      if (!mounted) return;
      setState(() => _starting = false);
      _showSnack("Bus belum di-assign untuk slot ini (field 'bus' kosong).");
      return;
    }

    try {
      await _gpsService.startTracking(busId: busId);

      if (!mounted) return;
      setState(() {
        _gpsActive = true;
        _starting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _starting = false);
      _showSnack("Gagal mulai GPS tracking: $e");
    }
  }

  Future<void> _completeTrip() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Action"),
        content: const Text("Complete this trip? GPS tracking will stop."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _completing = true);

    try {
      await _gpsService.stopTracking();
      await _loader.updateSlotStatus(widget.slot.id, "completed");

      if (!mounted) return;
      Navigator.pop(context, true); // return success
    } catch (e) {
      if (!mounted) return;
      _showSnack("Gagal menyelesaikan trip: $e");
    } finally {
      if (mounted) setState(() => _completing = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case "standby":
        return Colors.orange;
      case "on the way":
        return Colors.blue;
      case "completed":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case "standby":
        return Icons.timer;
      case "on the way":
        return Icons.directions_bus;
      case "completed":
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slot = widget.slot;
    final routeName =
        "${slot.route.originCampus.name} → ${slot.route.destinationCampus.name}";
    final busId = slot.bus ?? "";

    return Scaffold(
      appBar: AppBar(title: const Text("Live Trip Tracking")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card (similar style with StatusScreen)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routeName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Departure: ${slot.schedule.departureTime}",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        Chip(
                          backgroundColor:
                              _statusColor("on the way").withOpacity(0.15),
                          avatar: Icon(
                            _statusIcon("on the way"),
                            color: _statusColor("on the way"),
                          ),
                          label: Text(
                            "ON THE WAY",
                            style: TextStyle(
                              color: _statusColor("on the way"),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Chip(
                          backgroundColor: (_gpsActive
                                  ? Colors.green
                                  : Colors.grey)
                              .withOpacity(0.15),
                          avatar: Icon(
                            _gpsActive ? Icons.gps_fixed : Icons.gps_off,
                            color: _gpsActive ? Colors.green : Colors.grey,
                          ),
                          label: Text(
                            _gpsActive ? "GPS ACTIVE" : "GPS OFF",
                            style: TextStyle(
                              color: _gpsActive ? Colors.green : Colors.grey,
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

            const SizedBox(height: 20),

            // Map Card (re-uses your existing BusTrackingMap)
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 420,
                  child: _starting
                      ? const Center(child: CircularProgressIndicator())
                      : (busId.isEmpty
                          ? const Center(
                              child: Text(
                                "Bus ID kosong. Tidak bisa tracking.",
                                style: TextStyle(fontSize: 15),
                              ),
                            )
                          : BusTrackingMap(
                              busId: busId,
                              routeName: routeName,
                            )),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Seats card (kept consistent)
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Seats Available",
                        style: TextStyle(fontSize: 16)),
                    Text(
                      "${slot.availableSeats}/${slot.totalSeats}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Complete Trip Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _completing ? Colors.grey : Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _completing ? null : _completeTrip,
              child: _completing
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      "Complete Trip",
                      style: TextStyle(fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
