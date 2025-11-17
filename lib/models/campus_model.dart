import 'package:flutter/material.dart';

/// Model sederhana untuk merepresentasikan lokasi kampus, baik sebagai titik asal (origin)
/// atau tujuan (destination) dalam jadwal shuttle.
@immutable
class Campus {
  final String id;
  final String name;

  const Campus({
    required this.id,
    required this.name,
  });

  // --- Metode Konversi dari JSON (Firestore) ---
  /// Membuat instance [Campus] dari Map JSON yang diterima dari Firestore.
  factory Campus.fromJson(Map<String, dynamic> json) {
    return Campus(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  // --- Metode Konversi ke JSON (Firestore) ---
  /// Mengkonversi instance [Campus] menjadi Map JSON yang siap diunggah ke Firestore.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}