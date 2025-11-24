import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:beetle/models/shuttle_schedule_model.dart';
import 'package:beetle/models/shuttle_slot_model.dart';

class LoadRegistrations {
  // ⭐️ 1. Instance Field: Use the private field
  final FirebaseFirestore _firestore;

  // ⭐️ 2. Constructor: Allows dependency injection (optional firestore)
  LoadRegistrations({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<ShuttleSlot> getSlotDetails(
    ShuttleSchedule schedule,
    bool today,
    String newStatus,
  ) async {
    DateTime now = DateTime.now();
    // var startOfDay = DateTime(now.year, now.month, now.day);

    if (today == false) {
      now = now.add(const Duration(days: 1));
      // endOfDay = endOfDay.add(const Duration(days: 1));
    }
    // var endOfDay = startOfDay.add(const Duration(days: 1));

    final parts = schedule.departureTime.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    final fullDate = DateTime(now.year, now.month, now.day, hour, minute);

    // 1. Lakukan Query untuk mendapatkan QuerySnapshot
    final slotSnapshot = await _firestore
        .collection("shuttle_slots")
        .where("schedule.id", isEqualTo: schedule.id)
        .where("date", isEqualTo: fullDate)
        .limit(1)
        .get();
    // Tipe: QuerySnapshot

    // 2. Cek apakah ada dokumen yang ditemukan
    if (slotSnapshot.docs.isEmpty) {
      // Penanganan jika slot tidak ditemukan
      throw Exception("Slot perjalanan tidak ditemukan untuk jadwal ini.");
    }

    // 3. Ambil DocumentSnapshot pertama dari koleksi hasil
    final DocumentSnapshot slotDoc = slotSnapshot.docs.first;
    final slotId = slotDoc.id;

    // updateSlotStatus(slotId, newStatus);

    final DocumentSnapshot updatedDoc = await _firestore
        .collection("shuttle_slots")
        .doc(slotId)
        .get();
    final ShuttleSlot updatedSlot = ShuttleSlot.fromFirestore(updatedDoc);

    return updatedSlot;
  }

  Future<void> updateSlotStatus(String slotId, String newStatus) async {
    if (slotId.isEmpty) return;

    await _firestore.collection('shuttle_slots').doc(slotId).update({
      'status': newStatus,
      'lastUpdated':
          FieldValue.serverTimestamp(), // Tambahkan timestamp pembaruan
    });
  }

  Future<List<ShuttleSlot>> loadSchedulesWithRegistrations(
    String originCampus, {
    String? driverId,
    bool? today,
  }) async {
    DateTime now = DateTime.now();

    var startOfDay = DateTime(now.year, now.month, now.day);
    if (today == false) {
      startOfDay = startOfDay.add(const Duration(days: 1));
    }
    var endOfDay = startOfDay.add(const Duration(days: 1));

    // 1. Load all registrations for today
    final registrationSnapshot = await _firestore
        .collection("shuttle_registrations")
        .where("status", isEqualTo: "Booked")
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

    // 2. Extract schedule IDs from registrations
    final scheduleIds = registrationSnapshot.docs
        .map((doc) => doc["scheduleId"] as String)
        .toSet()
        .toList();

    // 3. Load corresponding schedules
    final schedulesSnapshot = await _firestore
        .collection("shuttle_schedules")
        .where(FieldPath.documentId, whereIn: scheduleIds)
        .get();

    final matchingSchedules = schedulesSnapshot.docs
        .map((doc) {
          final data = doc.data();
          data["id"] = doc.id;
          return ShuttleSchedule.fromJson(data);
        })
        .where(
          (schedule) =>
              schedule.route.originCampus.name.toLowerCase() ==
              originCampus.toLowerCase(),
        )
        .toList();

    if (matchingSchedules.isEmpty) {
      return [];
    }

    // 4. Load the actual shuttle slots
    Query slotQuery = _firestore
        .collection("shuttle_slots")
        .where(
          'schedule.id',
          whereIn: matchingSchedules.map((s) => s.id).toList(),
        )
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay));

    if (driverId != null) {
      slotQuery = slotQuery.where('driverId', isEqualTo: driverId);
    }

    final slotSnapshot = await slotQuery.get();
    if (slotSnapshot.docs.isEmpty) return [];

    // 5. Convert Firestore docs → Slot model
    final slots = slotSnapshot.docs
        .map((doc) => ShuttleSlot.fromFirestore(doc))
        .toList();

    // 6. Sort by departure time (not registration order)
    slots.sort((a, b) {
      final tA = a.schedule.departureTime;
      final tB = b.schedule.departureTime;
      return tA.compareTo(tB);
    });

    return slots;
  }
}
