import 'package:flutter/material.dart';
import 'package:beetle/pages/detail/calendar_view_screen.dart';
import 'package:beetle/pages/detail/schedule_view_screen.dart';
import 'package:beetle/pages/driver/driver_schedule_screen.dart';

/// ChoosenAction = RegistrationScheduleScreen
/// This acts as a container that decides whether to show
/// today's schedule or the registration calendar screen.
class ChoosenAction extends StatelessWidget {
  final bool isRegister;
  final String campusName;
  final String? userId;
  final String? role;

  const ChoosenAction({
    super.key,
    required this.isRegister,
    required this.campusName,
    this.userId,
    this.role,
  });

  String getTitleText() {
    return isRegister
        ? "Pendaftaran Shuttle"
        : "Jadwal Hari Ini";
  }

  Color getActionColor() {
    return isRegister
        ? Colors.teal
        : const Color.fromARGB(255, 58, 159, 243);
  }

  @override
  Widget build(BuildContext context) {
    final title = getTitleText();
    final color = getActionColor();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: color,
        centerTitle: true,
      ),
      body:role == 'driver' 
              ? DriverScheduleScreen(
                  originCampus: campusName,
                  userId: userId, // userId is the driver's ID
                  role: role,
                )
              : isRegister
                  ? CalendarViewScreen(originCampus: campusName)
                  : ScheduleViewScreen(originCampus: campusName),
    );
  }
}
