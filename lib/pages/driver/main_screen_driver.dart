import 'package:beetle/pages/profile/profile_screen.dart';
import 'package:beetle/pages/selection/campus_selection_screen.dart';
import 'package:flutter/material.dart';
// import 'package:beetle/widgets/navigation_bar.dart';
import 'package:google_fonts/google_fonts.dart';

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
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          title: Opacity(opacity: 1, 
          child: Text(
                      "BEETLE DRIVER",
                      style: GoogleFonts.iceberg(
                        fontWeight: FontWeight.bold,
                        fontSize: 38,
                        color: Colors.white,
                      ),
                    ),
          ), 
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 83, 64, 0),
          foregroundColor: Colors.white,),

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
