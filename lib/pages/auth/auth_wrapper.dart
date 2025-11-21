import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../home/main_screen_user.dart';
import '../driver/main_screen_driver.dart';
import '../admin/main_screen_admin.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ✅ User not logged in → go to login
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // ✅ User logged in → check Firestore
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
              // Firestore user doc missing → fix corruption
              FirebaseAuth.instance.signOut();
              return const LoginScreen();
            }

            final role = doc['role'] ?? "user"; // fallback

            if (role == "driver") {
              return MainScreenDriver(userId: uid, role: role,);
            } else if (role == "admin") {
              return const MainScreenAdmin();
            } else {
              return MainScreenUser(userId: uid);
            }
          },
        );
      },
    );
  }
}
