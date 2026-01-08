import 'package:beetle/controllers/load_registrations.dart';
import 'package:beetle/models/shuttle_slot_model.dart';
import 'package:flutter/material.dart';
import 'package:beetle/pages/livetracking/bus_tracking_screen.dart';

import 'package:beetle/widgets/schedule_information.dart';

class ScheduleViewScreen extends StatefulWidget {
  final String originCampus;

  const ScheduleViewScreen({super.key, required this.originCampus});

  @override
  State<ScheduleViewScreen> createState() => _ScheduleViewScreenState();
}

class _ScheduleViewScreenState extends State<ScheduleViewScreen> {
  late Future<List<ShuttleSlot>> _todaySchedulesFuture;

  @override
  void initState() {
    super.initState();
    final loadRegistrations = LoadRegistrations();
    _todaySchedulesFuture = loadRegistrations.loadSchedulesWithRegistrations(
      widget.originCampus,
    );
  }

  String _formatTime(dynamic time) {
    if (time is TimeOfDay) return time.format(context);
    if (time is DateTime) {
      return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    }
    if (time is String) return time;
    return "-";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<ShuttleSlot>>(
      future: _todaySchedulesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
      
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
      
        final slots = snapshot.data ?? [];
      
        if (slots.isEmpty) {
          return const Center(
            child: Text(
              "No available schedules for today.",
              style: TextStyle(fontSize: 16),
            ),
          );
        }
      
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: slots.length,
          itemBuilder: (context, index) {
            final slot = slots[index];
            final route = slot.route;
            final schedule = slot.schedule;
            final capacity = slot.totalSeats;
            final availableSeats = slot.availableSeats;
      
            Color statusColor(String status) {
              switch (status) {
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
      
            return Container(
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
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => ScheduleInformation.show(context, slot: slot),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Route Title
                        Text(
                          "${route.originCampus.name} → ${route.destinationCampus.name}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
      
                        const SizedBox(height: 8),
      
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 20,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatTime(schedule.departureTime),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
      
                        const SizedBox(height: 12),
      
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // capacity
                            Row(
                              children: [
                                Icon(
                                  Icons.people_alt_rounded,
                                  size: 20,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "$availableSeats / $capacity seats",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
      
                            // SLOT STATUS CHIP
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor(
                                  slot.status,
                                ).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                slot.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: statusColor(slot.status),
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
            );
          },
        );
      },
            ),
    );
  }
}
