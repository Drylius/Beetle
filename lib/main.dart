// import 'package:beetle/pages/home/main_screen_user.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:beetle/pages/auth/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:beetle/repositories/shuttle_repository.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  // 1. Pastikan inisialisasi widget sudah selesai sebelum memanggil inisialisasi Firebase

  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  try {
    // 2. Inisialisasi Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 3. Jalankan aplikasi setelah Firebase siap
    runApp(const MyApp());
  } catch (e) {
    // Penanganan error jika inisialisasi gagal
    runApp(ErrorApp(errorMessage: 'Gagal menginisialisasi Firebase: $e'));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeeTle',
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      // home: ElevatedButton(
      //   onPressed: () async {
      //     await FirebaseAuth.instance.signOut();
      //   },
      //   child: Text("Logout"),
      // ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String errorMessage;

  const ErrorApp({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Aplikasi Gagal Dimulai.\nDetail: $errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
