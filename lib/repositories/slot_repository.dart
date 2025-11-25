import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/shuttle_slot_model.dart';

class SlotRepository {
  final _db = FirebaseFirestore.instance;

  Future<List<ShuttleSlot>> getSlotsInRange(DateTime start, DateTime end) async {
    final snapshot = await _db
        .collection("shuttle_slots")
        .where("date", isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where("date", isLessThan: Timestamp.fromDate(end))
        .get();

    return snapshot.docs.map((doc) => ShuttleSlot.fromFirestore(doc)).toList();
  }

  Future<List<Map<String, dynamic>>> getDrivers() async {
    final snapshot =
        await _db.collection("users").where("role", isEqualTo: "driver").get();

    return snapshot.docs
        .map((d) => {"id": d.id, "name": d["name"]})
        .toList();
  }

  Future<void> updateSlot(String id, String? driverId, String? bus) {
    return _db.collection("shuttle_slots").doc(id).update({
      "driverId": driverId,
      "bus": bus,
    });
  }
}
