import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  final _controller = StreamController<UserModel?>.broadcast();
  Stream<UserModel?> get authStateChanges => _controller.stream;

  AuthService() {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        try {
          _currentUser = await _getUserData(user.uid);
        } catch (e) {
          _currentUser = null;
        }
      } else {
        _currentUser = null;
      }
      _controller.add(_currentUser);
    });
  }

  Future<UserModel> _getUserData(String uid) async {
    final doc = await _db.collection("users").doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      return UserModel(
        id: uid,
        email: data['email'],
        name: data['name'],
        avatar: data['avatar'],
      );
    } else {
      // Create user doc if it doesn't exist (e.g. first login)
      final user = _auth.currentUser;
      if (user != null) {
        await _db.collection("users").doc(uid).set({
          "id": uid,
          "email": user.email ?? "",
          "name": user.email?.split('@')[0] ?? "User",
          "avatar": "",
        });
        return UserModel(
          id: uid,
          email: user.email ?? "",
          name: user.email?.split('@')[0] ?? "User",
          avatar: "",
        );
      }
      throw Exception("User data not found");
    }
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> register(String email, String password) async {
    final res = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _db.collection("users").doc(res.user!.uid).set({
      "id": res.user!.uid,
      "email": email,
      "name": email.split('@')[0],
      "avatar": "",
    });
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> updateProfile({required String uid, String? name, String? avatar}) async {
    Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (avatar != null) data['avatar'] = avatar;

    if (data.isNotEmpty) {
      await _db.collection("users").doc(uid).update(data);
    }
  }
}
