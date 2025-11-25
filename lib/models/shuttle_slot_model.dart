import 'package:cloud_firestore/cloud_firestore.dart';
import 'shuttle_route_model.dart';
import 'shuttle_schedule_model.dart';

class ShuttleSlot {
  final String id;
  final DateTime date; // The date of this slot (selected from the calendar)
  final ShuttleSchedule
  schedule; // The fixed shuttle schedule (e.g. 08:00, 10:00)
  final ShuttleRoute route; // The route for this shuttle
  final int availableSeats; // Number of seats available
  final int totalSeats; // Optional: total number of seats

  /// ✅ NEW: driver assigned to the slot
  String? driverId;

  String? bus;

  /// ✅ NEW: status (standby, onTheWay, delayed, completed)
  String status;

  ShuttleSlot({
    required this.id,
    required this.date,
    required this.schedule,
    required this.route,
    required this.availableSeats,
    required this.totalSeats,
    this.driverId, // <--- NEW
    this.bus,
    this.status = "standby", // <--- NEW (default value)
  });

  factory ShuttleSlot.fromFirestore(DocumentSnapshot doc) {
    // 1. Ekstrak data mentah
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw StateError("Document data for slot ID ${doc.id} is null.");
    }

    // 2. Suntikkan ID dokumen ke dalam map data
    data['id'] = doc.id;

    // 3. Panggil factory fromJson yang sudah ada
    return ShuttleSlot.fromJson(data);
  }

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
      driverId: json['driverId'], // ✅ NEW
      bus: json['bus'], // ✅ NEW
      status: json['status'] ?? "standby", // ✅ NEW
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
      'driverId': driverId, // ✅ NEW
      'bus': bus,
      'status': status, // ✅ NEW
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
      driverId: null, // ✅ NEW
      bus: null,
      status: "standby", // ✅ NEW
    );
  }

  ShuttleSlot copyWith({
    String? id,
    DateTime? date,
    ShuttleSchedule? schedule,
    ShuttleRoute? route,
    int? availableSeats,
    int? totalSeats,
    String? driverId,
    String? bus,
    String? status,
  }) {
    return ShuttleSlot(
      id: id ?? this.id,
      date: date ?? this.date,
      schedule: schedule ?? this.schedule,
      route: route ?? this.route,
      availableSeats: availableSeats ?? this.availableSeats,
      totalSeats: totalSeats ?? this.totalSeats,
      // For nullable types like driverId and bus, we must use the spread operator
      // or check if the new value is explicitly null to allow clearing the value.
      // In this case, since the controller always provides a non-null String?
      // for the change, we can use the following logic:
      driverId: driverId ?? this.driverId,
      bus: bus ?? this.bus,
      status: status ?? this.status,
    );
  }
}
