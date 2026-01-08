import 'package:beetle/pages/my_reservation/my_reservation_screen.dart';
import 'package:beetle/pages/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:beetle/pages/home/home_page_user.dart';
import 'package:beetle/widgets/navigation_bar.dart';
import 'package:beetle/repositories/shuttle_repository.dart';

class MainScreenUser extends StatefulWidget {
  MainScreenUser({
    super.key,
    // required this.appTitle
    required this.userId,
    this.index
    });

  // final String appTitle;
  final String userId;
  final shuttleRepository = ShuttleRepository();
  final int? index;

 @override
  State<MainScreenUser> createState() {
    return _MainScreenUserState();
  }
}

class _MainScreenUserState extends State<MainScreenUser> {
  // int currentPageIndex = 0;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    // 2. Assign the value here. At this point, 'widget' is fully accessible.
    _selectedIndex = widget.index ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Opacity(opacity: 1, child: Text(
              "BeeTle",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                fontFamily: 'pacifico',
              )),), 
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 0, 49, 83),
          foregroundColor: Colors.white,),
        body: [HomePage(), MyReservationScreen(userId: widget.userId), ProfileScreen()][_selectedIndex],
        bottomNavigationBar: Navigation(
          currentIndex: _selectedIndex,
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      );
  }
}