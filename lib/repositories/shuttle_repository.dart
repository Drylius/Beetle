import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/campus_model.dart';
import '../models/shuttle_route_model.dart';
import '../models/shuttle_schedule_model.dart';
import '../models/shuttle_slot_model.dart';
import '../models/shuttle_registration_model.dart';
import 'package:intl/intl.dart';

class ShuttleRepository {
  final firestore.FirebaseFirestore _db = firestore.FirebaseFirestore.instance;

  Future<Map<String, dynamic>> loadReservationDetails(
    List<ShuttleRegistration> registrations,
  ) async {
    // Get all unique Slot IDs
    final slotIds = registrations.map((r) => r.slotId).toSet();

    final slotFutures = slotIds.map((id) => getSlotById(id)).toList();
    final slotResults = await Future.wait(slotFutures);

    // Convert to map for O(1) lookup
    final slotMap = {
      for (var slot in slotResults.whereType<ShuttleSlot>()) slot.id: slot,
    };

    // Same batching for Route IDs
    final routeIds = registrations.map((r) => r.routeId).toSet();

    final routeFutures = routeIds.map((id) => getRouteById(id)).toList();
    final routeResults = await Future.wait(routeFutures);

    final routeMap = {
      for (var route in routeResults.whereType<ShuttleRoute>()) route.id: route,
    };

    return {"slots": slotMap, "routes": routeMap};
  }

  // =======================================
  // GET INDIVIDUAL SLOT BY ID (for reservation)
  // =======================================
  Future<ShuttleSlot?> getSlotById(String slotId) async {
    try {
      final doc = await _db.collection("shuttle_slots").doc(slotId).get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      data['id'] = doc.id; // ensure the document ID is included

      return ShuttleSlot.fromJson(data);
    } catch (e) {
      print("Error fetching slot by ID: $e");
      return null;
    }
  }

  // =======================================
  // GET INDIVIDUAL ROUTE BY ID (for reservation)
  // =======================================
  Future<ShuttleRoute?> getRouteById(String routeId) async {
    try {
      final doc = await _db.collection("shuttle_routes").doc(routeId).get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      data['id'] = doc.id; // ensure the document ID is included

      return ShuttleRoute.fromJson(data);
    } catch (e) {
      print("Error fetching route by ID: $e");
      return null;
    }
  }

  // =========================
  // ======== CAMPUS =========
  // =========================
  Stream<List<Campus>> getCampuses() {
    return _db.collection('campuses').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Campus.fromJson(doc.data());
      }).toList();
    });
  }

  // =========================
  // ======== ROUTES =========
  // =========================
  Stream<List<ShuttleRoute>> getRoutes() {
    return _db.collection('shuttle_routes').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ShuttleRoute.fromJson(doc.data());
      }).toList();
    });
  }

  // ==========================
  // ======== SCHEDULES =======
  // ==========================
  Stream<List<ShuttleSchedule>> getSchedules() {
    return _db.collection('shuttle_schedules').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ShuttleSchedule.fromJson(doc.data());
      }).toList();
    });
  }

  // ========================
  // ======== SLOTS =========
  // ========================
  Stream<List<ShuttleSlot>> getSlotsByDate(DateTime date) async* {
    final weekday = DateFormat('EEEE').format(date);

    final schedulesStream = FirebaseFirestore.instance
        .collection('shuttle_schedules')
        .where('repeatDays', arrayContains: weekday)
        .where('isActive', isEqualTo: true)
        .snapshots();

    await for (final scheduleSnap in schedulesStream) {
      final futures = scheduleSnap.docs.map((scheduleDoc) async {
        final data = scheduleDoc.data();

        final schedule = ShuttleSchedule.fromJson({
          ...data,
          'id': scheduleDoc.id,
        });

        final parts = schedule.departureTime.split(':');
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        final fullDate = DateTime(
          date.year,
          date.month,
          date.day,
          hour,
          minute,
        );

        // Query real slot
        final realQuery = await FirebaseFirestore.instance
            .collection('shuttle_slots')
            .where('schedule.id', isEqualTo: schedule.id)
            .where('date', isEqualTo: Timestamp.fromDate(fullDate))
            .limit(1)
            .get();

        if (realQuery.docs.isNotEmpty) {
          final real = realQuery.docs.first;
          return ShuttleSlot.fromJson({...real.data(), 'id': real.id});
        }

        // Virtual slot
        final capacity = 20;
        // final parts = schedule.departureTime.split(':');
        // final hour = int.tryParse(parts[0]) ?? 0;
        // final minute = int.tryParse(parts[1]) ?? 0;
        // final fullTripDate = DateTime(
        //   date.year,
        //   date.month,
        //   date.day,
        //   hour,
        //   minute,
        // );

        return ShuttleSlot(
          id: "",
          date: fullDate,
          route: schedule.route,
          schedule: schedule,
          availableSeats: capacity,
          totalSeats: capacity,
          driverId: null,
          status: "standby",
        );
      }).toList();

      final slots = await Future.wait(futures);
      yield slots;
    }
  }

  /// ✅ Ensures that a Firestore slot document exists for this schedule/date
  Future<ShuttleSlot> ensureSlotExists(ShuttleSlot virtualSlot) async {
    final slotsRef = FirebaseFirestore.instance.collection('shuttle_slots');

    // 🔍 Look for existing slot (by schedule.id and date)
    final existing = await slotsRef
        .where('schedule.id', isEqualTo: virtualSlot.schedule.id)
        .where('date', isEqualTo: Timestamp.fromDate(virtualSlot.date))
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      // ✅ Slot already exists
      final doc = existing.docs.first;
      // print("Slot already exists with ID: ${doc.id}");
      return ShuttleSlot.fromJson({...doc.data(), 'id': doc.id});
    }

    // print("run kedua");

    // ❌ Slot doesn't exist — create a new one
    final newSlotData = {
      'schedule': virtualSlot.schedule.toJson(),
      'route': virtualSlot.route.toJson(),
      'date': Timestamp.fromDate(virtualSlot.date),
      'availableSeats': 20, // or pull from config
      'totalSeats': 20,
      'driverId': null,
      'status': 'standby',
    };

    // 🧾 Add to Firestore
    final newDoc = await slotsRef.add(newSlotData);

    // 🔁 Return as ShuttleSlot model
    return ShuttleSlot.fromJson({...newSlotData, 'id': newDoc.id});
  }

  // ===============================
  // ======== REGISTRATIONS ========
  // ===============================
  Stream<List<ShuttleRegistration>> getUserRegistrations(String userId) {
    return _db
        .collection('shuttle_registrations')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return ShuttleRegistration.fromJson(data);
          }).toList();
        });
  }

  // =================================
  // ======== REGISTER SHUTTLE =======
  // =================================
  Future<void> registerShuttle(
    ShuttleRegistration registration,
    ShuttleSlot slot,
  ) async {
    final slotRef = _db.collection('shuttle_slots').doc(slot.id);
    final registrationRef = _db.collection('shuttle_registrations').doc();

    // 🔍 Step 1: Check if user already registered for this schedule + date
    final existingRegistration = await _db
        .collection('shuttle_registrations')
        .where('userId', isEqualTo: registration.userId)
        .where('tripDate', isEqualTo: Timestamp.fromDate(registration.tripDate))
        .where('scheduleId', isEqualTo: registration.schedule.id)
        .limit(1)
        .get();

    if (existingRegistration.docs.isNotEmpty) {
      throw Exception('Kamu sudah terdaftar untuk jadwal ini.');
    }

    // 🚀 Step 2: Proceed to register using transaction
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(slotRef);

      if (!snapshot.exists) {
        throw Exception('Slot tidak ditemukan');
      }

      final currentAvailableSeats =
          snapshot.data()?['availableSeats'] as int? ?? 0;
      // final totalSeats = snapshot.data()?['totalSeats'] as int? ?? 0;

      if (currentAvailableSeats <= 0) {
        throw Exception('Slot sudah penuh');
      }

      final String currentStatus =
          snapshot.data()?['status'] as String? ?? 'standby';

      String newSlotStatus = currentStatus;

      if (currentAvailableSeats - 1 == 0){
        newSlotStatus = 'Full';
      }

      // ✅ Decrement seat count
      transaction.update(slotRef, {
        'availableSeats': FieldValue.increment(-1),
        'status': newSlotStatus,
      });

      // ✅ Save registration
      transaction.set(registrationRef, registration.toJson());
    });
  }

  // ======================================================
  // CANCEL RESERVATION (restore seat count)
  // ======================================================
  Future<void> cancelReservation(String registrationId, String slotId) async {
    final slotRef = _db.collection("shuttle_slots").doc(slotId);
    final registrationRef = _db
        .collection("shuttle_registrations")
        .doc(registrationId);

    await _db.runTransaction((transaction) async {
      final slotSnapshot = await transaction.get(slotRef);

      if (!slotSnapshot.exists) {
        throw Exception("Slot not found");
      }
      // 2. Ambil data penting dari Slot
      final currentAvailableSeats =
          slotSnapshot.data()?['availableSeats'] as int? ?? 0;
      final totalSeats = slotSnapshot.data()?['totalSeats'] as int? ?? 0;

      // Hitung kursi yang tersedia setelah pembatalan (+1)
      final newAvailableSeats = currentAvailableSeats + 1;

      // Tentukan status slot baru
      String newSlotStatus =
          slotSnapshot.data()?['status'] as String? ?? 'standby';

      // Logika Perubahan Status: Jika kursi tersedia kembali sama atau lebih dari total kapasitas,
      // berarti slot tersebut sekarang kosong kembali dan harus diaktifkan/dinonaktifkan sesuai logika bisnis Anda.
      // Jika Anda ingin status kembali ke 'standby' (jika sebelumnya 'Full' atau 'inActive' karena penuh):
      if (newAvailableSeats > 0 && newAvailableSeats <= totalSeats) {
        // Asumsi: Jika kursi tersedia > 0, statusnya kembali menjadi 'standby' atau 'onTheWay'
        // jika sebelumnya 'Full' atau 'inActive' karena penuh

        // Namun, jika maksud 'inActive' adalah slot tidak memiliki pendaftar sama sekali (kursi penuh):
        if (newAvailableSeats >= totalSeats) {
          // Jika semua kursi kosong, statusnya menjadi 'inActive'
          newSlotStatus = 'inActive';
        } else {
          // Jika ada kursi yang kembali dan status sebelumnya 'Full', kembalikan ke 'standby'
          // Jika status sebelumnya sudah 'onTheWay' atau 'standby', biarkan
          if (newSlotStatus == 'Full' || newSlotStatus == 'inActive') {
            newSlotStatus = 'standby';
          }
        }
      }
      // Increase available seat back by 1
      transaction.update(slotRef, {
        "availableSeats": firestore.FieldValue.increment(1),
      });

      // Update reservation status
      transaction.update(registrationRef, {"status": "Cancelled"});
    });
  }

  // =================================
  // ======== ADMIN HELPERS ==========
  // =================================
  Future<void> addCampus(Campus campus) async {
    await _db.collection('campuses').add(campus.toJson());
  }

  Future<void> addRoute(ShuttleRoute route) async {
    await _db.collection('shuttle_routes').add(route.toJson());
  }

  Future<void> addSchedule(ShuttleSchedule schedule) async {
    await _db.collection('shuttle_schedules').add(schedule.toJson());
  }

  Future<void> addSlot(ShuttleSlot slot) async {
    await _db.collection('shuttle_slots').add(slot.toJson());
  }

  Future<void> addRegistration(ShuttleRegistration registration) async {
    await _db.collection('shuttle_registrations').add(registration.toJson());
  }
}
