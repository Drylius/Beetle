// import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;          // Firebase UID
  final String name;
  final String email;
  final String campusId;   // or staff ID
  final String role;        // "user", "driver", "admin"

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.campusId,
    required this.role,
  });

  // Convert Firestore document to UserModel
  factory UserModel.fromJson(Map<String, dynamic> json, String docId) {
    return UserModel(
      id: docId,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      campusId: json['campusId'] ?? '',
      role: json['role'] ?? 'user',
    );
  }

  // Convert UserModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'name': name,
      'email': email,
      'campusId': campusId,
      'role': role,
    };
  }
}
