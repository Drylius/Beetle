import 'package:beetle/controllers/load_registrations.dart';
import 'package:beetle/models/shuttle_slot_model.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:beetle/models/shuttle_schedule_model.dart';
import 'package:beetle/pages/driver/status_screen.dart';
// import 'package:beetle/models/shuttle_registration_model.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class DriverScheduleScreen extends StatefulWidget {
  final String originCampus;
  final String? userId;
  final String? role;

  const DriverScheduleScreen({
    super.key,
    required this.originCampus,
    this.userId,
    this.role,
  });

  @override
  State<DriverScheduleScreen> createState() => _DriverScheduleScreenState();
}

class _DriverScheduleScreenState extends State<DriverScheduleScreen> {
  // This future will be updated whenever the day selection changes
  late Future<List<ShuttleSlot>> _schedulesFuture;

  // State: true for Today, false for Tomorrow (Default: Today)
  bool _isTodaySelected = true;

  // 1. New method to handle fetching schedules based on current state
  Future<void> _fetchSchedules() async {
    final loadRegistrations = LoadRegistrations();

    // Use setState to update the future and trigger FutureBuilder rebuild
    setState(() {
      _schedulesFuture = loadRegistrations.loadSchedulesWithRegistrations(
        widget.originCampus,
        driverId: widget.userId,
        // Pass the current state of the selection to the controller
        today: _isTodaySelected,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    // 2. Initialize the future by calling the new fetch method
    _fetchSchedules();
  }

  /// Utility to format time object/string into a displayable time string
  String _formatTime(dynamic time) {
    if (time is TimeOfDay) return time.format(context);
    if (time is DateTime) {
      return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    }
    if (time is String) return time;
    return "-";
  }

  // Helper function for the day selection buttons
  Widget _buildDayButton(String label, bool isTargetDayToday) {
    final bool isSelected = _isTodaySelected == isTargetDayToday;
    final Color primaryColor = Colors.teal;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: OutlinedButton(
          onPressed: () {
            // Update the state only if the button is not already selected
            if (_isTodaySelected != isTargetDayToday) {
              setState(() {
                _isTodaySelected = isTargetDayToday;

                // 3. Call fetch schedules after state change
                _fetchSchedules();

                final selectedText = _isTodaySelected ? 'Today' : 'Tomorrow';
                print(
                  'Boolean State: $_isTodaySelected. Selected Day: $selectedText',
                );
              });
            }
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: isSelected ? primaryColor : Colors.white,
            foregroundColor: isSelected ? Colors.white : primaryColor,
            side: BorderSide(color: primaryColor, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            elevation: isSelected ? 2 : 0,
            shadowColor: primaryColor.withOpacity(0.5),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "open":
        return Colors.green;
      case "full":
        return Colors.red;
      case "departed":
        return Colors.blueGrey;
      case "cancelled":
        return Colors.orange;
      case "completed":
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Day Selector Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDayButton("Today", true),
                _buildDayButton("Tomorrow", false),
              ],
            ),
          ),

          // 4. FIX: Use Expanded to constrain the height of the ListView
          Expanded(
            child: FutureBuilder<List<ShuttleSlot>>(
              // Use the dynamic future variable
              future: _schedulesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Terjadi kesalahan saat memuat jadwal: ${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                final schedules = snapshot.data ?? [];

                if (schedules.isEmpty) {
                  final dayText = _isTodaySelected ? 'hari ini' : 'besok';
                  return Center(
                    child: Text(
                      "Tidak ada shuttle yang memiliki pendaftaran $dayText.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    final slot = schedules[index];

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: ListTile(
                        title: Text(
                          // Displaying route name
                          '${slot.route.originCampus.name} → ${slot.route.destinationCampus.name}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          // Displaying departure time
                          'Waktu Keberangkatan: ${_formatTime(slot.schedule.departureTime)}',
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StatusScreen(
                                schedule: slot.schedule,
                                today:
                                    _isTodaySelected, // Pass the driver ID to the next screen
                                    slotId: slot.id,
                              ),
                            ),
                          );
                        },
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(slot.status),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            slot.status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
