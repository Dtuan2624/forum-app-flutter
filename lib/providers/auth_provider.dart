import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AppAuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();
  User? _user;
  bool _isLoading = true;

  AppAuthProvider() {
    _service.authStateChanges.listen((user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> login(String email, String password) async {
    await _service.login(email, password);
  }

  Future<void> register(String email, String password) async {
    await _service.register(email, password);
  }

  Future<void> logout() async {
    await _service.logout();
  }
}
