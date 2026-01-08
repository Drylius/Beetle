import 'package:flutter/material.dart';
import 'package:beetle/pages/detail/registration_schedule_screen.dart';
import 'package:beetle/widgets/image_background.dart';

class SelectCampusScreen extends StatelessWidget {
  final bool isRegister;
  final String? userId;
  final String? role;

  const SelectCampusScreen({super.key, required this.isRegister, this.userId, this.role});

  String getTitleText() {
    return isRegister
        ? 'Pendaftaran Shuttle'
        : 'Jadwal Hari Ini';
  }

  Color getActionColor() {
    return isRegister ? Colors.teal : const Color.fromARGB(255, 58, 159, 243);
  }

  void navigateToFinalDetail(BuildContext context, String campusName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) =>
            ChoosenAction(isRegister: isRegister, campusName: campusName, userId: userId, role: role,),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String titleText = getTitleText();

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: Colors.white,
          ),
        title: Text(titleText, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 0, 49, 83),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
              "Select pickup?",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 20),
              ImageBackgroundButton(
                imagePath: "assets/images/binus-alsut.jpeg",
                text: "BINUS ALSUT",
                onPressed: () => navigateToFinalDetail(context, "Alam Sutera"),
              ),
              const SizedBox(height: 20),
              ImageBackgroundButton(
                imagePath: "assets/images/binus-anggrek.jpeg",
                text: "BINUS ANGGREK",
                onPressed: () => navigateToFinalDetail(context, "Anggrek"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
