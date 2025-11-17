import 'package:flutter/material.dart';

class Navigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  
  const Navigation({
    super.key,
    required this.currentIndex,
    required this.onTap
    });

  @override
  // int currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: onTap,
      indicatorColor: const Color.fromARGB(255, 157, 224, 255),
      selectedIndex: currentIndex,
      destinations: [
        NavigationDestination(
          selectedIcon: Icon(Icons.home_filled),
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.airport_shuttle),
          label: 'Reservation',
        ),
        NavigationDestination(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}