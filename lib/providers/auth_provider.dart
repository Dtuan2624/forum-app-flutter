import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AppAuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  UserModel? _user;
  bool _isLoading = true;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  AppAuthProvider() {
    _service.authStateChanges.listen((user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
    // Initial check
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    await _service.login(email, password);
  }

  Future<void> register(String email, String password) async {
    await _service.register(email, password);
  }

  Future<void> logout() async {
    await _service.logout();
  }

  Future<void> updateProfile({String? name, String? avatar}) async {
    if (_user != null) {
      await _service.updateProfile(uid: _user!.id, name: name, avatar: avatar);
    }
  }
}
