import 'package:flutter/material.dart';

class MainScreenDriver extends StatefulWidget {
  const MainScreenDriver({super.key});

  @override
  State<MainScreenDriver> createState() => _MainScreenDriverState();
}

class _MainScreenDriverState extends State<MainScreenDriver> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    Center(child: Text("Driver: Today's Shuttle Schedule")),
    Center(child: Text("Driver: QR Check-in / Scan Page")),
    Center(child: Text("Driver: Profile / Logout")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BeeTle Driver"),
        backgroundColor: Colors.orange,
      ),

      body: _screens[_selectedIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.directions_bus),
            label: "Today's Shuttle",
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner),
            label: "Scan",
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
