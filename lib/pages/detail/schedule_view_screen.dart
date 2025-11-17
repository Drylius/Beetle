import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
import 'package:beetle/models/shuttle_schedule_model.dart';
// import 'package:beetle/models/shuttle_registration_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleViewScreen extends StatefulWidget {
  final String originCampus;

  const ScheduleViewScreen({super.key, required this.originCampus});

  @override
  State<ScheduleViewScreen> createState() => _ScheduleViewScreenState();
}

class _ScheduleViewScreenState extends State<ScheduleViewScreen> {
  late Future<List<ShuttleSchedule>> _todaySchedulesFuture;

  @override
  void initState() {
    super.initState();
    _todaySchedulesFuture = _loadSchedulesWithRegistrations();
  }

  /// ✅ NEW: Fetch schedules ONLY IF users registered today
  Future<List<ShuttleSchedule>> _loadSchedulesWithRegistrations() async {
    DateTime today = DateTime.now().add(const Duration(days: 3));

    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final registrationSnapshot = await FirebaseFirestore.instance
        .collection("shuttle_registrations")
        .where(
          "tripDate",
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where("tripDate", isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy("tripDate")
        .get();

    if (registrationSnapshot.docs.isEmpty) {
      return [];
    }

    // Extract scheduleIds based on registration order (sorted by tripDate)
    final scheduleIdsOrderedByTripDate = <String>[];

    for (var doc in registrationSnapshot.docs) {
      final id = doc["scheduleId"] as String;

      if (!scheduleIdsOrderedByTripDate.contains(id)) {
        scheduleIdsOrderedByTripDate.add(id);
      }
    }

    final schedulesSnapshot = await FirebaseFirestore.instance
        .collection("shuttle_schedules")
        .where(FieldPath.documentId, whereIn: scheduleIdsOrderedByTripDate)
        .get();

    final allSchedules = schedulesSnapshot.docs.map((doc) {
      final data = doc.data();
      data["id"] = doc.id;
      return ShuttleSchedule.fromJson(data);
    }).toList();

    // Filter first
    final filteredSchedules = allSchedules.where((s) {
      return s.route.originCampus.name.toLowerCase() ==
          widget.originCampus.toLowerCase();
    }).toList();

    if (filteredSchedules.isEmpty) {
      return [];
    }

    // Then sort based on tripDate order
    filteredSchedules.sort((a, b) {
      return scheduleIdsOrderedByTripDate
          .indexOf(a.id)
          .compareTo(scheduleIdsOrderedByTripDate.indexOf(b.id));
    });

    final scheduleWithRegistration = await FirebaseFirestore.instance.collection("shuttle_slots").where(
      'schedule.id',
      whereIn: filteredSchedules.map((s) => s.id).toList(),
    ).where(
      'status',
      whereIn: ['standby'],
    ).get();

    final activeSchedule = filteredSchedules.where((schedule) {
      return scheduleWithRegistration.docs.any((doc) => doc['schedule.id'] == schedule.id);
    }).toList();

    return activeSchedule;
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
      body: FutureBuilder<List<ShuttleSchedule>>(
        future: _todaySchedulesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          }

          final schedules = snapshot.data ?? [];

          if (schedules.isEmpty) {
            return const Center(
              child: Text(
                "Tidak ada shuttle yang memiliki pendaftaran hari ini.",
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              final schedule = schedules[index];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: ListTile(
                  title: Text(
                    '${schedule.route.originCampus.name} → ${schedule.route.destinationCampus.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${_formatTime(schedule.departureTime)}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
