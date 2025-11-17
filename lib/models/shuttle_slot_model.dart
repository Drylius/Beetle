import 'package:cloud_firestore/cloud_firestore.dart';
import 'shuttle_route_model.dart';
import 'shuttle_schedule_model.dart';

class ShuttleSlot {
  final String id;
  final DateTime date; // The date of this slot (selected from the calendar)
  final ShuttleSchedule schedule; // The fixed shuttle schedule (e.g. 08:00, 10:00)
  final ShuttleRoute route; // The route for this shuttle
  final int availableSeats; // Number of seats available
  final int totalSeats; // Optional: total number of seats

  /// ✅ NEW: driver assigned to the slot
  String? driverId;

  /// ✅ NEW: status (standby, onTheWay, delayed, completed)
  String status;

  ShuttleSlot({
    required this.id,
    required this.date,
    required this.schedule,
    required this.route,
    required this.availableSeats,
    required this.totalSeats,
    this.driverId,             // <--- NEW
    this.status = "standby",   // <--- NEW (default value)
  });

  /// Create ShuttleSlot from Firestore document or JSON
  factory ShuttleSlot.fromJson(Map<String, dynamic> json) {
    Timestamp? dateTimestamp = json['date'] is Timestamp ? json['date'] : null;

    return ShuttleSlot(
      id: json['id'] ?? '',
      date: dateTimestamp != null
          ? dateTimestamp.toDate()
          : DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      schedule: json['schedule'] != null
          ? ShuttleSchedule.fromJson(json['schedule'])
          : ShuttleSchedule.empty(),
      route: json['route'] != null
          ? ShuttleRoute.fromJson(json['route'])
          : ShuttleRoute.empty(),
      availableSeats: json['availableSeats'] ?? 0,
      totalSeats: json['totalSeats'] ?? 0,
      driverId: json['driverId'],                 // ✅ NEW
      status: json['status'] ?? "standby",        // ✅ NEW
    );
  }

  /// Convert ShuttleSlot to Firestore-friendly map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': Timestamp.fromDate(date),
      'schedule': schedule.toJson(),
      'route': route.toJson(),
      'availableSeats': availableSeats,
      'totalSeats': totalSeats,
      'driverId': driverId,                       // ✅ NEW
      'status': status,                           // ✅ NEW
    };
  }

  /// Helper for empty object
  factory ShuttleSlot.empty() {
    return ShuttleSlot(
      id: '',
      date: DateTime.now(),
      schedule: ShuttleSchedule.empty(),
      route: ShuttleRoute.empty(),
      availableSeats: 0,
      totalSeats: 0,
      driverId: null,            // ✅ NEW
      status: "standby",         // ✅ NEW
    );
  }
}
