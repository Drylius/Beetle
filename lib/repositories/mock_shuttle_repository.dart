// import 'dart:async';
// import 'package:beetle/models/campus_model.dart';
// import 'package:beetle/models/shuttle_route_model.dart';
// import 'package:beetle/models/shuttle_slot_model.dart';
// import 'package:beetle/models/shuttle_schedule_model.dart';
// import 'package:beetle/models/shuttle_registration_model.dart';
// import 'package:beetle/repositories/abstract_shuttle_repository.dart';
// import 'package:intl/intl.dart';

// // Implementasi ini sepenuhnya menggunakan data statis dan simulasi waktu tunda.
// class MockShuttleRepository implements AbstractShuttleRepository {
//   // --- Data Mock ---
//   final List<ShuttleSlot> _mockSlots = [
//     ShuttleSlot(
//       slotId: 's1',
//       routeId: 'r1',
//       time: '07:30',
//       capacity: 30,
//       available: 30,
//     ),
//     ShuttleSlot(
//       slotId: 's2',
//       routeId: 'r1',
//       time: '10:00',
//       capacity: 30,
//       available: 30,
//     ),
//     ShuttleSlot(
//       slotId: 's3',
//       routeId: 'r2',
//       time: '13:30',
//       capacity: 30,
//       available: 30,
//     ),
//     ShuttleSlot(
//       slotId: 's4',
//       routeId: 'r1',
//       time: '17:00',
//       capacity: 30,
//       available: 30,
//     ),
//     ShuttleSlot(
//       slotId: 's5',
//       routeId: 'r2',
//       time: '19:30',
//       capacity: 30,
//       available: 30,
//     ),
//   ];

//   final List<ShuttleRoute> _mockRoutes = [
//     ShuttleRoute(
//       id: 'r1',
//       originCampusId: 'Anggrek',
//       destinationCampusId: 'Alam Sutera',
//       name: 'Anggrek -> Alam Sutera',
//     ),
//     ShuttleRoute(
//       id: 'r2',
//       originCampusId: 'Alam Sutera',
//       destinationCampusId: 'Anggrek',
//       name: 'Alam Sutera -> Anggrek',
//     ),
//   ];

//   final List<ShuttleSchedule> _mockSchedules = [
//     ShuttleSchedule(
//       id: 'sch1',
//       availableSeats: 30,
//       time: '07:00 AM',
//       route: 'Anggrek -> Alam Sutera',
//       status: 'On Time',
//     ),
//     ShuttleSchedule(
//       id: 'sch2',
//       availableSeats: 30,
//       time: '08:30 AM',
//       route: 'Alam Sutera -> Anggrek',
//       status: 'Delayed (15 min)',
//     ),
//     ShuttleSchedule(
//       id: 'sch3',
//       availableSeats: 30,
//       time: '10:00 AM',
//       route: 'Anggrek -> Alam Sutera',
//       status: 'On Time',
//     ),
//     ShuttleSchedule(
//       id: 'sch4',
//       availableSeats: 30,
//       time: '12:00 PM',
//       route: 'Alam Sutera -> Anggrek',
//       status: 'Canceled',
//     ),
//     ShuttleSchedule(
//       id: 'sch5',
//       availableSeats: 30,
//       time: '13:45 PM',
//       route: 'Anggrek -> Alam Sutera',
//       status: 'On Time',
//     ),
//     ShuttleSchedule(
//       id: 'sch6',
//       availableSeats: 30,
//       time: '15:30 PM',
//       route: 'Alam Sutera -> Anggrek',
//       status: 'On Time',
//     ),
//   ];

//   final List<ShuttleSchedule> _mockBookedSchedules = [
//     ShuttleSchedule(
//       id: 'b001',
//       time: '09:30',
//       route: 'Anggrek -> Alam Sutera',
//       status: 'On Time',
//       availableSeats: 15,
//     ),
//     ShuttleSchedule(
//       id: 'b002',
//       time: '12:30',
//       route: 'Anggrek -> Alam Sutera',
//       status: 'On Time',
//       availableSeats: 5,
//     ),
//     ShuttleSchedule(
//       id: 'b003',
//       time: '14:00',
//       route: 'Anggrek -> Alam Sutera',
//       status: 'On Time',
//       availableSeats: 20,
//     ),
//   ];
  
//   final StreamController<List<ShuttleSchedule>> _bookedSchedulesController =
//       StreamController<List<ShuttleSchedule>>.broadcast();

//   Stream<List<ShuttleSchedule>> fetchBookedSchedules(String userId) {
//     // Mengembalikan stream dari controller, yang akan mengirimkan data setiap kali ada perubahan
//     return _bookedSchedulesController.stream;
//   }

//   Future<void> cancelBooking(String scheduleId, String userId) async {
//     print('Mock API call: Cancelling booking $scheduleId for user $userId');

//     // Tunggu sebentar untuk simulasi jaringan
//     await Future.delayed(const Duration(milliseconds: 800));

//     // Logika Mock: Hapus item dari daftar dan kirim update ke stream
//     _mockBookedSchedules.removeWhere((s) => s.id == scheduleId);

//     // Kirim data baru ke stream agar UI (StreamBuilder) otomatis terupdate
//     _bookedSchedulesController.add(_mockBookedSchedules);
//   }

//   final Map<String, int> _dailyBookedCount = {};

//   final String _mockUserId = 'user_999';

//   String _createDailyKey(String slotId, DateTime date) {
//     final dateFormatter = DateFormat('yyyy-MM-dd');
//     return '$slotId-${dateFormatter.format(date)}';
//   }
//   // -----------------

//   @override
//   Future<List<ShuttleSlot>> fetchSlots(Campus campus, DateTime date) async {
//     // Simulasi penundaan jaringan 500ms
//     await Future.delayed(const Duration(milliseconds: 500));

//     final routeIdToFilter = campus.name == 'Anggrek' ? 'r1' : 'r2';

//     final filteredSlots = _mockSlots
//         .where((slot) => slot.routeId == routeIdToFilter)
//         .toList();

//     // Logika Mock: Tidak ada shuttle di hari Minggu
//     if (date.weekday == DateTime.sunday) {
//       return [];
//     }

//     // Mengembalikan data mock
//     return filteredSlots.map((slot) {
//       final key = _createDailyKey(slot.slotId, date);
//       final booked = _dailyBookedCount[key] ?? 0;

//       return ShuttleSlot(
//         slotId: slot.slotId,
//         routeId: slot.routeId,
//         time: slot.time,
//         capacity: slot.capacity,
//         available: slot.capacity - booked,
//       );
//     }).toList();
//   }

//   Future<ShuttleRegistration> registerShuttle(
//     ShuttleSlot slot,
//     DateTime date,
//   ) async {
//     // 1. Simulate network delay
//     await Future.delayed(const Duration(milliseconds: 500));

//     // 2. Perform BUSINESS LOGIC: Check availability
//     if (slot.available <= 0) {
//       throw Exception('Slot penuh. Tidak dapat melakukan pendaftaran.');
//     }

//     final key = _createDailyKey(slot.slotId, date);
//     final booked = _dailyBookedCount[key] ?? 0;

//     // 3. Persist/Update the data (in mock: update the map)
//     _dailyBookedCount[key] = booked + 1;

//     // 4. Create and return the Registration record
//     final dateFormatter = DateFormat('yyyy-MM-dd');
//     final registration = ShuttleRegistration(
//       registrationId: 'reg_${DateTime.now().millisecondsSinceEpoch}',
//       userId: _mockUserId,
//       routeId: slot.routeId,
//       departureTime: slot.time,
//       date: dateFormatter.format(date),
//       status: 'Booked',
//     );

//     return registration;
//   }

//   @override
//   Future<ShuttleRoute> getRouteById(String routeId) async {
//     await Future.delayed(const Duration(milliseconds: 100));
//     try {
//       return _mockRoutes.firstWhere((route) => route.id == routeId);
//     } catch (e) {
//       throw Exception('Route not found');
//     }
//   }

//   @override
//   Stream<List<ShuttleSchedule>> fetchSchedules(Campus departureCampus) {
//     // Untuk simulasi real-time, kita bisa menggunakan Stream.periodic
//     // yang mengirim data mock setiap 5 detik.
//     return Stream.periodic(const Duration(seconds: 5), (i) {
//       // Mengambil nama kampus (misalnya 'Anggrek' atau 'Alam Sutera')
//       final campusName = departureCampus.name.toString().split('.').last;

//       // Filter data mock berdasarkan rute yang dimulai dari kampus ini
//       final filteredList = _mockSchedules.where((schedule) {
//         return schedule.route.startsWith(campusName);
//       }).toList();

//       // Untuk simulasi update, kita bisa memodifikasi status setiap beberapa iterasi
//       if (i % 2 == 1) {
//         // Simulasi perubahan status
//         filteredList[0] = ShuttleSchedule(
//           id: filteredList[0].id,
//           availableSeats: filteredList[0].availableSeats,
//           time: filteredList[0].time,
//           route: filteredList[0].route,
//           status: 'Delayed (${i + 1} min)',
//         );
//       }
//       return filteredList;
//     });
//   }
// }
