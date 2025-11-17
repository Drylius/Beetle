import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'shuttle_schedule_model.dart';

@immutable
class ShuttleRegistration {
  final String id;
  final String userId;
  final String? userName; // Optional: for display in admin views later
  final String slotId;
  final String routeId;
  final String scheduleId;
  final DateTime timestamp; // when user registered
  final DateTime tripDate; // ✅ actual date of the shuttle trip
  final String status; // "Booked", "Cancelled", etc.
  final ShuttleSchedule schedule; // Optional embedded snapshot

  const ShuttleRegistration({
    required this.id,
    required this.userId,
    required this.slotId,
    required this.routeId,
    required this.scheduleId,
    required this.timestamp,
    required this.tripDate,
    this.userName,
    this.status = "Booked",
    required this.schedule,
  });

  // ✅ From JSON (Firestore)
  factory ShuttleRegistration.fromJson(Map<String, dynamic> json) {
    DateTime createdTime;
    DateTime tripDateValue;

    // Handle timestamp parsing
    final timeData = json['timestamp'];
    if (timeData is Timestamp) {
      createdTime = timeData.toDate();
    } else if (timeData is String) {
      createdTime = DateTime.tryParse(timeData) ?? DateTime.now();
    } else {
      createdTime = DateTime.now();
    }

    // ✅ Handle tripDate parsing (this is new)
    final tripData = json['tripDate'];
    if (tripData is Timestamp) {
      tripDateValue = tripData.toDate();
    } else if (tripData is String) {
      tripDateValue = DateTime.tryParse(tripData) ?? DateTime.now();
    } else {
      tripDateValue = DateTime.now();
    }

    ShuttleSchedule scheduleObj;
    if (json['schedule'] != null) {
      scheduleObj = ShuttleSchedule.fromJson(
        Map<String, dynamic>.from(json['schedule']),
      );
    } else {
      scheduleObj = ShuttleSchedule.empty();
    }

    return ShuttleRegistration(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      slotId: json['slotId'] ?? '',
      routeId: json['routeId'] ?? '',
      scheduleId: json['scheduleId'] ?? '',
      timestamp: createdTime,
      tripDate: tripDateValue, // ✅ new
      userName: json['userName'],
      status: json['status'] ?? 'Booked',
      schedule: scheduleObj,
    );
  }

  // ✅ To JSON (Firestore)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'slotId': slotId,
      'routeId': routeId,
      'scheduleId': scheduleId,
      'timestamp': Timestamp.fromDate(timestamp),
      'tripDate': Timestamp.fromDate(tripDate), // ✅ new
      'status': status,
      'schedule': schedule.toJson(),
    };
  }

  // ✅ copyWith helper
  ShuttleRegistration copyWith({
    String? id,
    String? userId,
    String? userName,
    String? slotId,
    String? routeId,
    String? scheduleId,
    DateTime? timestamp,
    DateTime? tripDate, // ✅ new
    String? status,
    ShuttleSchedule? schedule,
  }) {
    return ShuttleRegistration(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      slotId: slotId ?? this.slotId,
      routeId: routeId ?? this.routeId,
      scheduleId: scheduleId ?? this.scheduleId,
      timestamp: timestamp ?? this.timestamp,
      tripDate: tripDate ?? this.tripDate, // ✅ new
      status: status ?? this.status,
      schedule: schedule ?? this.schedule,
    );
  }
}
