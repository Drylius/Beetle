import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../pages/auth/auth_wrapper.dart';
import 'package:flutter/material.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// STREAM: real-time auth state (login/logout listener)
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Get UserModel by Firebase UID
  Future<UserModel?> getUserById(String uid) async {
    final doc = await _db.collection("users").doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromJson(doc.data()!, doc.id);
  }

  /// SIGN UP + SAVE USER INFO TO FIRESTORE USERS COLLECTION
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required String studentId,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    final newUser = UserModel(
      id: uid,
      name: name,
      email: email,
      campusId: studentId,
      role: "user", // default role
    );

    await _db.collection("users").doc(uid).set(newUser.toJson());

    return newUser;
  }

  /// LOGIN
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return getUserById(credential.user!.uid);
  }

  /// LOGOUT
  Future<void> signOut() async => await _auth.signOut();
}
