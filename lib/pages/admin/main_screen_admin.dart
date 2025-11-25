import 'package:beetle/pages/admin/admin_schedule_window_screen.dart';
import 'package:beetle/pages/admin/admin_slot_assignment_screen.dart';
import 'package:beetle/pages/profile/profile_screen.dart';
import 'package:flutter/material.dart';

class MainScreenAdmin extends StatefulWidget {
  const MainScreenAdmin({super.key});

  @override
  State<MainScreenAdmin> createState() => _MainScreenAdminState();
}

class _MainScreenAdminState extends State<MainScreenAdmin> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    AdminSlotAssignmentScreen(),
    AdminScheduleWindowScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("BeeTle Admin"),) ,
        backgroundColor: Colors.red,
      ),

      body: _screens[_selectedIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: "Assign",
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: "Schedule Window",
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
