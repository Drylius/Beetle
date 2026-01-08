import 'package:beetle/pages/livetracking/bus_tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:beetle/models/shuttle_slot_model.dart';
import 'package:beetle/widgets/map_widget.dart';
import 'package:url_launcher/url_launcher.dart';

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

          child: Column(
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Transform.rotate(
                      angle: 90 * 3.14 / 180,
                      child: const Icon(
                        Icons.navigation,
                        size: 28,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      slot.route.destinationCampus.name,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
                      const Text(
                        'Driver',
                        style: TextStyle(color: Colors.grey),
                      ),
                      FutureBuilder<String?>(
                        future: slot.fetchDriverName(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          }
                          // Fallback: If name is null but ID exists, show ID. Else Unassigned.
                          final displayText =
                              snapshot.data ??
                              (slot.driverId != null
                                  ? "ID: ${slot.driverId}"
                                  : "Unassigned");
                          return Text(
                            displayText,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Departure Time',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        slot.schedule.departureTime,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        slot.status.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Bus', style: TextStyle(color: Colors.grey)),
                      Text(
                        slot.bus ?? "-",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Capacity',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        "${slot.availableSeats} / ${slot.totalSeats}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pickup Point',
                        style: TextStyle(color: Colors.grey),
                      ),
                      if (slot.route.pickupPoint != null &&
                          slot.route.pickupPoint!.isNotEmpty)
                        InkWell(
                          onTap: () async {
                            String url = slot.route.pickupPoint!;
                            if (!url.startsWith('http')) {
                              url = 'https://$url';
                            }
                            final uri = Uri.tryParse(url);
                            if (uri != null) {
                              try {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              } catch (e) {
                                debugPrint("Error launching URL: $e");
                              }
                            }
                          },
                          child: Text(
                            "Location Link",
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        )
                      else
                        const Text(
                          "-",
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  if (slot.status == "on the way") ...[
                    //map link only for "onTheWay" status, standby for testing.
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton.icon(
                        onPressed: () async {
                          // 1. Added async here
                          // 2. Await the name properly
                          final fetchedName = await slot.fetchDriverName();

                          if (!context.mounted)
                            return; // Safety check for context

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BusTrackingScreen(
                                busId: slot.bus!,
                                routeName:
                                    "${slot.route.originCampus.name} ➝ ${slot.route.destinationCampus.name}",
                                departureTime: slot.schedule.departureTime,
                                // 3. Use the fetched string, provide a fallback if null
                                driverName: fetchedName ?? "Unassigned",
                                busName: slot.bus!,
                                status: slot.status,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.map),
                        label: const Text("Track Bus Location"),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
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
