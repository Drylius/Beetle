import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../repositories/auth_repository.dart';
import '../../models/user_model.dart';
import '../home/main_screen_user.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
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
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _studentIdController.dispose();
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

  void signUp() async {
    _validateEmail();
    _validatePassword();
    if (_emailErrorText != null || _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid email address.")));
      return;
    }
    if (_studentIdController.text.trim().length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Student ID must be exactly 10 digits.")));
      return;
    }
    if (_passwordErrorText != null || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid password.")));
      return;
    }

    setState(() => _loading = true);

    try {
      UserModel? user = await _authRepo.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        studentId: _studentIdController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => MainScreenUser(userId: user.id)),
        // Predikat (kondisi): Route<dynamic> route) => false
        // Ini memastikan tidak ada route lama yang dipertahankan.
        (Route<dynamic> route) => false, 
      );
    } catch (e) {
      String message = e.toString();
      if (message.contains('email-already-in-use')) {
        message = "An account with this email already exists.";
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF003153),
              Color(0xFF2BB5A3),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: "Full Name",
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                
                      TextField(
                        controller: _studentIdController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: const InputDecoration(
                          labelText: "Student ID",
                          prefixIcon: Icon(Icons.badge),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                
                      TextField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.email),
                          errorText: _emailErrorText,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (_) {
                          if (_emailErrorText != null) _validateEmail();
                        },
                      ),
                      const SizedBox(height: 12),
                
                      TextField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock),
                          errorText: _passwordErrorText,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (_) {
                          if (_passwordErrorText != null) _validatePassword();
                        },
                      ),
                      const SizedBox(height: 24),
                
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _loading ? null : signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF003153),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Sign Up", style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 95, 232, 253))),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black54.withOpacity(0.3),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Text(
                      "Have an account? Log In",
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
