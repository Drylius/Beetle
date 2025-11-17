import 'package:flutter/material.dart';
import 'package:beetle/pages/detail/registration_schedule_screen.dart';
import 'package:beetle/widgets/image_background.dart';

class SelectCampusScreen extends StatelessWidget {
  final bool isRegister;

  const SelectCampusScreen({super.key, required this.isRegister});

  String getTitleText() {
    return isRegister
        ? 'Pilih Kampus: Pendaftaran Shuttle'
        : 'Pilih Kampus: Jadwal Hari Ini';
  }

  Color getActionColor() {
    return isRegister ? Colors.teal : const Color.fromARGB(255, 58, 159, 243);
  }

  void navigateToFinalDetail(BuildContext context, String campusName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) =>
            ChoosenAction(isRegister: isRegister, campusName: campusName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String titleText = getTitleText();
    final Color actionColor = getActionColor();

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText, style: const TextStyle(color: Colors.white)),
        backgroundColor: actionColor,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
