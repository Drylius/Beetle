import 'package:beetle/pages/home/main_screen_user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:beetle/models/shuttle_slot_model.dart';
import 'package:beetle/models/shuttle_registration_model.dart';
import 'package:beetle/repositories/shuttle_repository.dart';
import 'package:beetle/widgets/schedule_card.dart';
import 'package:beetle/pages/my_reservation/my_reservation_screen.dart';
import 'package:beetle/repositories/schedule_window_repo.dart';
import 'package:beetle/models/schedule_window_model.dart';

class CalendarViewScreen extends StatefulWidget {
  final String originCampus;

  const CalendarViewScreen({super.key, required this.originCampus});

  @override
  State<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  DateTime? firstSelectable;
  DateTime? lastSelectable;

  final ShuttleRepository _repository = ShuttleRepository();

  String get formattedDate =>
      DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_selectedDate);

  void _onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
  }

  /// ❌ User cannot register for TODAY (D-0)
  bool _isToday(DateTime selected) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final picked = DateTime(selected.year, selected.month, selected.day);

    return picked.isAtSameMomentAs(today);
  }

  /// ✔ Check if selected date is D-1 (tomorrow)
  bool _isDminusOne(DateTime selected) {
    final now = DateTime.now();
    final tomorrow = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));

    final picked = DateTime(selected.year, selected.month, selected.day);

    return picked.isAtSameMomentAs(tomorrow);
  }

  /// ✔ Check if current time is past 14:00
  bool _isPastDeadline() {
    final now = DateTime.now();
    
    // return now.hour >= 14;
    return false;
  }

  /// ✅ REGISTER SHUTTLE
  Future<void> _registerForSlot(ShuttleSlot slot) async {
    try {
      // 🔥 Use logged in user ID
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // ❌ If D-1 AND after 14:00 → cannot register
      if (_isDminusOne(_selectedDate) && _isPastDeadline()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pendaftaran untuk besok ditutup pukul 14:00"),
          ),
        );
        return;
      }

      if (_isToday(_selectedDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Tidak dapat mendaftar untuk hari ini."),
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

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => MainScreenUser(userId: registration.userId, index: 1,),
          ),
          (Route<dynamic> route) => false,
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

  final ScheduleWindowRepository windowRepo = ScheduleWindowRepository();
  ScheduleWindow? window;
  String windowState = "loading";

  @override
  void initState() {
    super.initState();
    _loadWindow();
  }

  Future<void> _loadWindow() async {
    final data = await windowRepo.getActiveWindow();

    setState(() {
      window = data;

      if (data == null) {
        windowState = "no_window";
        return;
      }

      final today = DateTime.now();

      // Compute FIRST & LAST selectable
      firstSelectable = today.isBefore(data.startDate) ? data.startDate : today;

      lastSelectable = data.endDate;

      // Update state (active / upcoming / closed)
      if (today.isBefore(data.startDate)) {
        windowState = "upcoming";
      } else if (today.isAfter(data.endDate)) {
        windowState = "closed";
      } else {
        windowState = "active";
      }
    });

    // ⭐ Validate selection AFTER firstSelectable & lastSelectable are set
    _validateSelectedDate();
  }

  void _validateSelectedDate() {
    if (firstSelectable == null || lastSelectable == null) return;

    if (_selectedDate.isBefore(firstSelectable!)) {
      setState(() => _selectedDate = firstSelectable!);
    }
    if (_selectedDate.isAfter(lastSelectable!)) {
      setState(() => _selectedDate = lastSelectable!);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 If still loading window data
    if (windowState == "loading") {
      return const Center(child: CircularProgressIndicator());
    }

    // 🔥 If admin has not set any window
    if (windowState == "no_window") {
      return const Center(
        child: Text(
          "Pendaftaran belum dibuka oleh admin.",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    // 🔥 If window is closed
    if (windowState == "closed") {
      return const Center(
        child: Text(
          "Pendaftaran telah ditutup. Tunggu jadwal berikutnya.",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    final today = DateTime.now();

    return Column(
      children: [
        // 🔵 Info banner (only in UPCOMING)
        if (today.isBefore(window!.startDate))
          Container(
            width: double.infinity,
            color: Colors.orange.shade100,
            padding: const EdgeInsets.all(12),
            child: Text(
              "Pendaftaran dimulai pada "
              "${DateFormat('dd MMM yyyy').format(window!.startDate)}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        // 🔵 Calendar picker
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
                firstDate: firstSelectable!,
                lastDate: lastSelectable!,
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

        // 🔵 Shuttle Slot Stream
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

              // Filter by origin campus
              final filteredSlots = slots.where((slot) {
                return slot.route.originCampus.name.trim().toLowerCase() ==
                    widget.originCampus.trim().toLowerCase();
              }).toList();

              if (filteredSlots.isEmpty) {
                return const Center(
                  child: Text("Jadwal untuk hari yang dipilih tidak tersedia."),
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
