import 'package:flutter/material.dart';
import '../models/shuttle_slot_model.dart';
import 'schedule_information.dart';

class ScheduleCard extends StatelessWidget {
  final ShuttleSlot slot;
  final VoidCallback? onRegister;

  const ScheduleCard({super.key, required this.slot, this.onRegister});

  @override
  Widget build(BuildContext context) {
    final routeName = slot.route.originCampus.name + " to " + slot.route.destinationCampus.name;
    final seats = slot.availableSeats;
    final depTime = slot.schedule.departureTime.split(':').length == 2
        ? TimeOfDay(
            hour: int.parse(slot.schedule.departureTime.split(':')[0]),
            minute: int.parse(slot.schedule.departureTime.split(':')[1]),
          )
        : TimeOfDay(hour: 0, minute: 0);
    

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => ScheduleInformation.show(context, slot: slot),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          title: Text(
            routeName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            "Departure: ${depTime.hour.toString().padLeft(2, '0')}:${depTime.minute.toString().padLeft(2, '0')} | Seats left: $seats",
          ),
          trailing: onRegister != null
              ? ElevatedButton(
                  onPressed: onRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Register", style: TextStyle(color: Color.fromARGB(255, 245, 247, 169)),),
                )
              : null,
        ),
      ),
    );
  }
}