import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:beetle/models/shuttle_slot_model.dart';
import 'package:beetle/models/shuttle_registration_model.dart';
import 'package:beetle/repositories/shuttle_repository.dart';
import 'package:beetle/widgets/schedule_card.dart';
import 'package:beetle/pages/my_reservation/my_reservation_screen.dart';

class CalendarViewScreen extends StatefulWidget {
  final String originCampus;

  const CalendarViewScreen({super.key, required this.originCampus});

  @override
  State<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  final ShuttleRepository _repository = ShuttleRepository();

  String get formattedDate =>
      DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_selectedDate);

  void _onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
  }

  /// ✅ Helper untuk mengecek apakah tanggal yang dipilih adalah D-2, D-3, dst.
  bool _isBeyondDminusOne(DateTime selected) {
    final now = DateTime.now();

    // 1. Dapatkan tanggal hari ini (tengah malam, 00:00:00)
    final todayMidnight = DateTime(now.year, now.month, now.day);

    // 2. Dapatkan tanggal yang dipilih (tengah malam)
    final selectedMidnight = DateTime(
      selected.year,
      selected.month,
      selected.day,
    );

    if(selectedMidnight.isAtSameMomentAs(todayMidnight) || selectedMidnight.isBefore(todayMidnight)){
      return true;
    }
    return false;
    // 3. Hitung selisih hari (Duration)
    // final difference = selectedMidnight.difference(todayMidnight);

    // 4. Cek: Jika selisihnya lebih besar dari 1 hari (yaitu, 2 hari atau lebih)
    // D-2 (lusa) = 2 hari, D-3 = 3 hari, dst.
    // return difference.inDays > 1;
  }

  /// ✅ Helper to check if selected date is D-1 relative to today
  bool _isDminusOne(DateTime selected) {
    final now = DateTime.now();
    final tomorrow = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));

    final selectedMidnight = DateTime(
      selected.year,
      selected.month,
      selected.day,
    );

    return selectedMidnight.isAtSameMomentAs(tomorrow);
  }

  /// ✅ Helper to check if current time is after deadline (14:00)
  bool _isPastDeadline() {
    final now = DateTime.now();
    return now.hour >= 14;
  }

  /// ✅ REGISTER SHUTTLE
  Future<void> _registerForSlot(ShuttleSlot slot) async {
    try {
      // 🔥 Use logged in user ID
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // ✅ Check D-1 rule
      if (_isDminusOne(_selectedDate) && _isPastDeadline()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pendaftaran untuk D-1 ditutup pukul 14:00"),
          ),
        );
        return;
      }

      if (_isBeyondDminusOne(_selectedDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Jadwal terpilih sudah selesai"),
          ),
        );
        return;
      }

      var ensuredSlot = await _repository.ensureSlotExists(slot);

      final parts = ensuredSlot.schedule.departureTime.split(':');
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      final fullTripDate = DateTime(
        ensuredSlot.date.year,
        ensuredSlot.date.month,
        ensuredSlot.date.day,
        hour,
        minute,
      );
      // Create a registration model
      final registration = ShuttleRegistration(
        id: '',
        userId: userId, // ✅ No more mock user!
        slotId: ensuredSlot.id,
        routeId: ensuredSlot.route.id,
        scheduleId: ensuredSlot.schedule.id,
        timestamp: DateTime.now(),
        tripDate: fullTripDate,
        schedule: ensuredSlot.schedule,
      );

      await _repository.registerShuttle(registration, ensuredSlot);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Berhasil mendaftar shuttle dari ${ensuredSlot.route.originCampus.name} ke ${ensuredSlot.route.destinationCampus.name}",
            ),
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MyReservationScreen(userId: registration.userId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        if (e.toString().contains('Kamu sudah terdaftar')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kamu sudah terdaftar untuk jadwal ini.'),
            ),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal mendaftar: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Calendar picker
        Container(
          color: Colors.teal.shade100,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const Text(
                "Pilih Tanggal Keberangkatan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 0)),
                lastDate: DateTime.now().add(const Duration(days: 30)),
                onDateChanged: _onDateChanged,
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            "Tanggal terpilih: $formattedDate",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),

        const Divider(height: 1),

        Expanded(
          child: StreamBuilder<List<ShuttleSlot>>(
            stream: _repository.getSlotsByDate(_selectedDate),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text("Terjadi kesalahan: ${snapshot.error}"),
                );
              }

              final slots = snapshot.data ?? [];

              // ✅ Show ALL shuttle schedules that match the selected campus
              final filteredSlots = slots.where((slot) {
                return slot.route.originCampus.name.trim().toLowerCase() ==
                    widget.originCampus.trim().toLowerCase();
              }).toList();

              if (filteredSlots.isEmpty) {
                return const Center(
                  child: Text(
                    "Belum ada pengguna yang mendaftar untuk jadwal ini.",
                  ),
                );
              }

              return ListView.builder(
                itemCount: filteredSlots.length,
                itemBuilder: (context, index) {
                  final slot = filteredSlots[index];
                  return ScheduleCard(
                    slot: slot,
                    onRegister: () => _registerForSlot(slot),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
