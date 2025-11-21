import 'package:beetle/pages/profile/profile_screen.dart';
import 'package:beetle/pages/selection/campus_selection_screen.dart';
import 'package:flutter/material.dart';

class MainScreenDriver extends StatefulWidget {
  final String userId;
  final String role;

  const MainScreenDriver({super.key, required this.userId, required this.role});

  @override
  State<MainScreenDriver> createState() => _MainScreenDriverState();
}

class _MainScreenDriverState extends State<MainScreenDriver> {
  int _selectedIndex = 0;
  late List<Widget> _screens; 

  @override
  void initState() {
    super.initState();
    // 2. Initialize the list here, inside initState,
    //    where 'widget' is guaranteed to be available.
    _screens = [
      SelectCampusScreen(
        isRegister: false,
        // ⭐️ FIX: widget is now accessible here
        userId: widget.userId,
        role: widget.role,
      ),
      ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("BeeTle Driver")),
        backgroundColor: Colors.orange,
      ),

      body: _screens[_selectedIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.directions_bus),
            label: "My Schedule",
          ),
          NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
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
