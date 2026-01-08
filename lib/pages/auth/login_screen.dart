import 'package:flutter/material.dart';
import 'package:beetle/repositories/auth_repository.dart';
import 'package:beetle/models/user_model.dart';
import '../home/main_screen_user.dart';
import '../admin/main_screen_admin.dart';
import '../driver/main_screen_driver.dart';
import 'signup_screen.dart';
import 'package:provider/provider.dart';
import 'package:beetle/controllers/schedule_window_controller.dart';
import 'package:beetle/repositories/schedule_window_repo.dart';
import 'package:google_fonts/google_fonts.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  String? _emailErrorText;
  String? _passwordErrorText;
  final AuthRepository _authRepo = AuthRepository();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        _validateEmail();
      }
    });
    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        _validatePassword();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    if (email.isNotEmpty && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email)) {
      setState(() => _emailErrorText = "Invalid email format");
    } else {
      setState(() => _emailErrorText = null);
    }
  }

  void _validatePassword() {
    final password = _passwordController.text;
    if (password.isNotEmpty && password.length < 6) {
      setState(() => _passwordErrorText = "Password must be at least 6 characters");
    } else {
      setState(() => _passwordErrorText = null);
    }
  }

  void login() async {
    setState(() => _loading = true);

    try {
      UserModel? user = await _authRepo.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid email or password")),
        );
        return;
      }

      // Role based navigation disini bisa dihapus karena sudah di-handle di AuthWrapper
      if (user.role == "admin") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(
              create: (_) =>
                  ScheduleWindowController(ScheduleWindowRepository())
                    ..loadWindow(),
              child: const MainScreenAdmin(),
            ),
          ),
        );
      } else if (user.role == "driver") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainScreenDriver(userId: user.id, role: user.role),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainScreenUser(userId: user.id)),
        );
      }

    } catch (e) {
      String message = e.toString();
      if (message.contains('user-not-found')) {
        message = "No user found for that email.";
        setState(() => _emailErrorText = "User not found");
      } else if (message.contains('wrong-password')) {
        message = "Wrong password provided.";
        setState(() => _passwordErrorText = "Wrong password");
      } else if (message.contains('invalid-credential')) {
        message = "Invalid email or password.";
        setState(() => _passwordErrorText = "Wrong password");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF003153), // Navy blue
              Color(0xFF2BB5A3), // Teal
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "BEETLE",
                      style: GoogleFonts.iceberg(
                        fontWeight: FontWeight.bold,
                        fontSize: 84,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "SHUTTLE",
                      style: GoogleFonts.iceberg(
                        fontWeight: FontWeight.bold,
                        fontSize: 42,
                        color: Colors.white,
                      )
                    )
                  ],
                ),
                const SizedBox(height: 30),

                // WHITE CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 12,
                        color: Colors.black.withOpacity(0.2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email),
                          labelText: "Email",
                          // errorText: _emailErrorText,
                          border: const OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.next,
                        onChanged: (_) {
                          if (_emailErrorText != null) _validateEmail();
                        },
                      ),
                      const SizedBox(height: 14),

                      TextField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          labelText: "Password",
                          // errorText: _passwordErrorText,
                          border: const OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.done,
                        onChanged: (_) {
                          if (_passwordErrorText != null) _validatePassword();
                        },
                        onSubmitted: (_) => _loading ? null : login(),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF003153),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _loading ? null : login,
                          child: _loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color.fromARGB(255, 95, 232, 253),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black54.withOpacity(0.3),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(
                        color: Colors.white,
                        // backgroundColor: Colors.black54.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
