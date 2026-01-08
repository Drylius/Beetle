import 'package:flutter/material.dart';
import 'package:beetle/models/shuttle_schedule_model.dart';
import 'package:beetle/models/shuttle_slot_model.dart';
import 'package:beetle/controllers/load_registrations.dart';
import 'package:beetle/pages/driver/driver_trip_tracking_screen.dart';

class StatusScreen extends StatefulWidget {
  final ShuttleSchedule schedule;
  final bool today;
  final String slotId;

  const StatusScreen({
    super.key,
    required this.schedule,
    required this.today,
    required this.slotId,
  });

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  final LoadRegistrations loader = LoadRegistrations();
  late Future<ShuttleSlot> _slotFuture;

  @override
  void initState() {
    super.initState();
    _slotFuture = loader.getSlotDetails(
      widget.schedule,
      widget.today,
      "",
      widget.slotId,
    );
  }

  Future<void> _updateStatus(String slotId, String newStatus) async {
    final bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Action"),
        content: Text(
          "Are you sure you want to change status to '$newStatus'?",
        ),
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

    if (!confirm) return;

    await loader.updateSlotStatus(slotId, newStatus);

    setState(() {
      _slotFuture = loader.getSlotDetails(
        widget.schedule,
        widget.today,
        "",
        widget.slotId,
      );
    });
  }

  Future<void> _openTracking(ShuttleSlot slot) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DriverTripTrackingScreen(slot: slot)),
    );

    // Refresh slot data after coming back
    setState(() {
      _slotFuture = loader.getSlotDetails(
        widget.schedule,
        widget.today,
        "",
        widget.slotId,
      );
    });
  }

  Color statusColor(String status) {
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

  IconData statusIcon(String status) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trip Status")),
      body: FutureBuilder<ShuttleSlot>(
        future: _slotFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Error: ${snapshot.error}",
                    ), // This will likely say "Slot not found"
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _slotFuture = loader.getSlotDetails(
                        widget.schedule,
                        widget.today,
                        "",
                        widget.slotId,
                      );
                    }),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            return const Center(child: CircularProgressIndicator());
          }

          final slot = snapshot.data!;

          // Button mapping
          String buttonText = "";
          String? nextStatus;
          bool enabled = true;

          switch (slot.status) {
            case "standby":
              buttonText = "Start Trip";
              nextStatus = "on the way";
              break;

            case "on the way":
              buttonText = "Complete Trip";
              nextStatus = "completed";
              break;

            case "completed":
              buttonText = "Trip Completed";
              enabled = false;
              break;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card
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
                          "${slot.route.originCampus.name} → ${slot.route.destinationCampus.name}",
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

                        // Status Chip
                        Chip(
                          backgroundColor: statusColor(
                            slot.status,
                          ).withOpacity(0.15),
                          avatar: Icon(
                            statusIcon(slot.status),
                            color: statusColor(slot.status),
                          ),
                          label: Text(
                            slot.status.toUpperCase(),
                            style: TextStyle(
                              color: statusColor(slot.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Seats card
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
                        const Text(
                          "Seats Available",
                          style: TextStyle(fontSize: 16),
                        ),
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

                const SizedBox(height: 40),

                // Wrap the entire button section
                if (!widget.today) ...[
                  // 1. Logic for "Tomorrow" or Future trips
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: null, // This disables the button
                    child: const Text(
                      "Trip only available on schedule date",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                ] else ...[
                  // Main Buttons (based on status)
                  if (slot.status == "standby") ...[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        await _updateStatus(slot.id, "on the way");

                        final updatedSlot = await loader.getSlotDetails(
                          widget.schedule,
                          widget.today,
                          "",
                          widget.slotId,
                        );

                        if (!mounted) return;
                        await _openTracking(updatedSlot);
                      },
                      child: const Text(
                        "Start Trip",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ] else if (slot.status == "on the way") ...[
                    // ✅ Resume Tracking
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _openTracking(slot),
                      child: const Text(
                        "Resume Tracking",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ✅ Complete Trip
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _updateStatus(slot.id, "completed"),
                      child: const Text(
                        "Complete Trip",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ] else ...[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: null,
                      child: const Text(
                        "Trip Completed",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
