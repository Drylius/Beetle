import 'package:flutter/material.dart';
import 'package:beetle/repositories/shuttle_repository.dart';
import 'package:beetle/models/shuttle_registration_model.dart';
import 'package:beetle/models/shuttle_slot_model.dart';
import 'package:beetle/models/shuttle_route_model.dart';
import 'package:intl/intl.dart';

class MyReservationScreen extends StatelessWidget {
  final String userId;
  final ShuttleRepository _repository = ShuttleRepository();

  MyReservationScreen({super.key, required this.userId});

  void _showCancelDialog(
    BuildContext context,
    ShuttleRegistration reservation,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Reservation?"),
        content: const Text(
          "Are you sure you want to cancel this shuttle reservation? "
          "This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // close dialog

              try {
                await _repository.cancelReservation(
                  reservation.id,
                  reservation.slotId,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Reservation cancelled successfully."),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Failed to cancel reservation: $e"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              "Yes, Cancel",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(
    BuildContext context,
    ShuttleRegistration reservation,
    ShuttleSlot slot,
    ShuttleRoute route,
  ) {
    final formattedDate = DateFormat(
      'EEEE, dd MMM yyyy',
      'id_ID',
    ).format(slot.date);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: ListTile(
        title: Text(
          "${route.originCampus.name} ➝ ${route.destinationCampus.name}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            "Date: $formattedDate\nDeparture: ${reservation.schedule.departureTime}",
            style: const TextStyle(fontSize: 14),
          ),
        ),
        trailing: reservation.status.toLowerCase() == "booked"
            ? TextButton(
                onPressed: () => _showCancelDialog(context, reservation),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.red),
                ),
              )
            : const Chip(
                label: Text("Cancelled"),
                backgroundColor: Colors.grey,
              ),
      ),
    );
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(":");
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("My Reservations")),
        backgroundColor: Colors.teal,
      ),

      // ✅ First stream: listen to user's reservations (real-time update)
      body: StreamBuilder<List<ShuttleRegistration>>(
        stream: _repository.getUserRegistrations(userId),
        builder: (context, regSnapshot) {
          if (regSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (regSnapshot.hasError) {
            return Center(child: Text("Error: ${regSnapshot.error}"));
          }

          final activeReservations = (regSnapshot.data ?? [])
              .where((r) => r.status.toLowerCase() == "booked")
              .toList();

          if (activeReservations.isEmpty) {
            return const Center(
              child: Text(
                "You don't have any active reservations.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // ✅ Second Future (batch fetch slots + routes only once)
          return FutureBuilder<Map<String, dynamic>>(
            future: _repository.loadReservationDetails(activeReservations),
            builder: (context, detailSnapshot) {
              if (!detailSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              // ✅ lookup maps (id → object)
              final Map<String, ShuttleSlot> slots =
                  detailSnapshot.data!['slots'];
              final Map<String, ShuttleRoute> routes =
                  detailSnapshot.data!['routes'];

              // 🕒 Filter out past slots (only show today or future)
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);

              final upcoming = activeReservations.where((reservation) {
                final slot = slots[reservation.slotId];
                if (slot == null) return false;

                final slotDate = DateTime(
                  slot.date.year,
                  slot.date.month,
                  slot.date.day,
                );

                // ✅ Keep only slots today or later
                return slotDate.isAtSameMomentAs(today) ||
                    slotDate.isAfter(today);
              }).toList();

              // 🎯 Split reservations by routeId
              final List<ShuttleRegistration> route001Reservations = [];
              final List<ShuttleRegistration> route002Reservations = [];

              for (var r in upcoming) {
                if (r.routeId == "route001") {
                  route001Reservations.add(r);
                } else if (r.routeId == "route002") {
                  route002Reservations.add(r);
                }
              }

              // ⭐ Sort upcoming list by actual date + time
              upcoming.sort((a, b) {
                final slotA = slots[a.slotId]!;
                final slotB = slots[b.slotId]!;

                final timeA = _parseTime(a.schedule.departureTime);
                final timeB = _parseTime(b.schedule.departureTime);

                final dateTimeA = DateTime(
                  slotA.date.year,
                  slotA.date.month,
                  slotA.date.day,
                  timeA.hour,
                  timeA.minute,
                );

                final dateTimeB = DateTime(
                  slotB.date.year,
                  slotB.date.month,
                  slotB.date.day,
                  timeB.hour,
                  timeB.minute,
                );

                return dateTimeA.compareTo(dateTimeB);
              });

              if (upcoming.isEmpty) {
                return const Center(
                  child: Text(
                    "You have no upcoming reservations.",
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              return ListView(
                children: [
                  // ==============================
                  // SECTION 1: Anggrek - Alam Sutera
                  // ==============================
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 176, 209, 238),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "Anggrek - Alam Sutera",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 0, 49, 83),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Reservations",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (route001Reservations.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        "Anggrek - Alam Sutera Reservations",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...route001Reservations.map((reservation) {
                      final slot = slots[reservation.slotId];
                      final route = routes[reservation.routeId];
                      if (slot == null || route == null)
                        return const SizedBox.shrink();

                      return _buildReservationCard(
                        context,
                        reservation,
                        slot,
                        route,
                      );
                    }).toList(),
                  ],

                  // ==============================
                  // SECTION 2: Alam Sutera - Anggrek
                  // ==============================
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "Alam Sutera - Anggrek",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Reservations",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (route002Reservations.isNotEmpty) ...[
                    ...route002Reservations.map((reservation) {
                      final slot = slots[reservation.slotId];
                      final route = routes[reservation.routeId];
                      if (slot == null || route == null)
                        return const SizedBox.shrink();

                      return _buildReservationCard(
                        context,
                        reservation,
                        slot,
                        route,
                      );
                    }).toList(),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}
