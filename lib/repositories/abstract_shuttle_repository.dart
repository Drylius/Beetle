import 'dart:async';
import 'package:beetle/models/campus_model.dart';
import 'package:beetle/models/shuttle_slot_model.dart';
import 'package:beetle/models/shuttle_schedule_model.dart';

/// Kontrak wajib untuk semua implementasi Shuttle Repository.
/// Ini memastikan bahwa UI (Screen/Widget) tidak peduli apakah data
/// datang dari Mock, API, atau Firebase.
abstract class AbstractShuttleRepository {
  /// Mengambil daftar slot yang tersedia berdasarkan kampus dan tanggal.
  Future<List<ShuttleSlot>> fetchSlots(Campus campus, DateTime date);

  /// Mendapatkan jadwal shuttle secara real-time (Stream) berdasarkan kampus keberangkatan.
  Stream<List<ShuttleSchedule>> fetchSchedules(Campus departureCampus);
}
