import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:provider/provider.dart';
import '../home/main_screen_user.dart';
import '../driver/main_screen_driver.dart';
import '../admin/main_screen_admin.dart';
import '/controllers/schedule_window_controller.dart';
import '/repositories/schedule_window_repo.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 🔥 Not logged in
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        final uid = snapshot.data!.uid;

        return FutureBuilder(
          future: FirebaseFirestore.instance.collection("users").doc(uid).get(),
          builder: (context, roleSnapshot) {
            if (!roleSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final doc = roleSnapshot.data!;

            if (!doc.exists) {
              FirebaseAuth.instance.signOut();
              return const LoginScreen();
            }

            final role = doc['role'] ?? "user";

            // 👨‍✈️ DRIVER
            if (role == "driver") {
              return MainScreenDriver(userId: uid, role: role);
            }

            // 🧑‍💼 ADMIN → WRAP WITH PROVIDER HERE
            if (role == "admin") {
              return ChangeNotifierProvider(
                create: (_) => ScheduleWindowController(
                  ScheduleWindowRepository(),
                )..loadWindow(),
                child: const MainScreenAdmin(),
              );
            }

            // 👤 NORMAL USER
            return MainScreenUser(userId: uid);
          },
        );
      },
    );
  }
}
