import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleWindow {
  final DateTime startDate;
  final DateTime endDate;

  ScheduleWindow({required this.startDate, required this.endDate});

  factory ScheduleWindow.fromMap(Map<String, dynamic> map) {
    return ScheduleWindow(
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
    );
  }
}
