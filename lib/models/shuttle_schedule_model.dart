import 'package:cloud_firestore/cloud_firestore.dart';
import 'shuttle_route_model.dart';

class ShuttleSchedule {
  final String id;
  final ShuttleRoute route;
  final String departureTime; // e.g. "07:30"
  final List<String> repeatDays; // e.g. ["Monday", "Wednesday"]
  final bool isActive;
  final Timestamp createdAt;

  ShuttleSchedule({
    required this.id,
    required this.route,
    required this.departureTime,
    required this.repeatDays,
    required this.isActive,
    required this.createdAt,
  });

  /// ✅ Empty factory (for default / placeholder cases)
  factory ShuttleSchedule.empty() {
    return ShuttleSchedule(
      id: '',
      route: ShuttleRoute.empty(),
      departureTime: '',
      repeatDays: [],
      isActive: true,
      createdAt: Timestamp.now(),
    );
  }

  /// ✅ Create from Firestore document or JSON
  factory ShuttleSchedule.fromJson(Map<String, dynamic> json) {
    return ShuttleSchedule(
      id: json['id'] ?? '',
      route: json['route'] != null
          ? ShuttleRoute.fromJson(Map<String, dynamic>.from(json['route']))
          : ShuttleRoute.empty(),
      departureTime: json['departureTime'] ?? '',
      repeatDays: (json['repeatDays'] is Iterable)
          ? List<String>.from(json['repeatDays'])
          : [],
      isActive: json['isActive'] ?? json['active'] ?? true, // ✅ prefer isActive
      createdAt: json['createdAt'] is Timestamp
          ? json['createdAt']
          : Timestamp.now(),
    );
  }

  /// ✅ Convert to Firestore map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'route': route.toJson(),
      'departureTime': departureTime,
      'repeatDays': repeatDays,
      'isActive': isActive, // ✅ use the actual value, not always true
      'createdAt': createdAt,
    };
  }
}
