import 'package:beetle/pages/selection/campus_selection_screen.dart';
import 'package:beetle/widgets/image_background.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void navigateToBinusLocation(BuildContext context, bool isRegister) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => SelectCampusScreen(isRegister: isRegister),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ImageBackgroundButton(
            imagePath: "assets/images/binus-alsut.jpeg", 
            text: "Today's Schedule", 
            onPressed: () => navigateToBinusLocation(context, false)
            ),
          const SizedBox(height: 20),
          ImageBackgroundButton(
            imagePath: "assets/images/binus-anggrek.jpeg", 
            text: "Register Shuttle", 
            onPressed: () => navigateToBinusLocation(context, true)
            ),
        ],
      )
    );
  }
}