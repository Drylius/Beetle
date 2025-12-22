import 'package:flutter/material.dart';
import 'package:beetle/models/shuttle_slot_model.dart';


class ScheduleInformation extends StatelessWidget {
  final ShuttleSlot slot;

  const ScheduleInformation({super.key, required this.slot});

  static void show(BuildContext context, {required ShuttleSlot slot}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScheduleInformation(slot: slot);
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),

            child:
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Schedule Information",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          slot.route.originCampus.name,
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Transform.rotate(
                          angle: 90 * 3.14 / 180,
                          child: const Icon(Icons.navigation, size: 28, color: Colors.black54)),
                      ),
                      Expanded(
                        child: Text(
                          slot.route.destinationCampus.name,
                          textAlign: TextAlign.start,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  // Better Practice: Column of Rows
                  // Keeps labels and values aligned and grouped together.
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Driver', style: TextStyle(color: Colors.grey)),
                          Text(slot.driverId ?? "Unassigned", style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Departure Time', style: TextStyle(color: Colors.grey)),
                          Text(slot.schedule.departureTime, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Status', style: TextStyle(color: Colors.grey)),
                          Text(slot.status.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Bus', style: TextStyle(color: Colors.grey)),
                          Text(slot.bus ?? "-", style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Capacity', style: TextStyle(color: Colors.grey)),
                          Text("${slot.availableSeats} / ${slot.totalSeats}", 
                            style: const TextStyle(fontWeight: FontWeight.bold
                            )
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Pickup Point', style: TextStyle(color: Colors.grey)),
                          Text("New DB for map links pls", 
                            style: const TextStyle(fontWeight: FontWeight.bold
                            )
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Close"),
                    
                  ),
                ],
              ),
        ),
      ),
    );
  }
}