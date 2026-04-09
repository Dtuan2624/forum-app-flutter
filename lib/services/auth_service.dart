import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';

class AuthService {
  final _userBox = Hive.box('users');
  final _settingsBox = Hive.box('settings');

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  final _controller = StreamController<UserModel?>.broadcast();
  Stream<UserModel?> get authStateChanges => _controller.stream;

  AuthService() {
    _init();
  }

  void _init() {
    final userData = _settingsBox.get('current_user');
    if (userData != null) {
      _currentUser = UserModel(
        id: userData['id'],
        email: userData['email'],
        name: userData['name'],
        avatar: userData['avatar'],
      );
      _controller.add(_currentUser);
    }
  }

  Future<void> login(String email, String password) async {
    // Hive stores data as key-value pairs. 
    // We can iterate over values to find the user.
    final users = _userBox.values.toList();
    
    final userMap = users.firstWhere(
      (u) => u['email'] == email && u['password'] == password,
      orElse: () => throw Exception("Invalid credentials"),
    );

    _currentUser = UserModel(
      id: userMap['id'],
      email: userMap['email'],
      name: userMap['name'],
      avatar: userMap['avatar'],
    );

    await _settingsBox.put('current_user', {
      'id': _currentUser!.id,
      'email': _currentUser!.email,
      'name': _currentUser!.name,
      'avatar': _currentUser!.avatar,
    });

    _controller.add(_currentUser);
  }

  Future<void> register(String email, String password) async {
    final users = _userBox.values.toList();
    if (users.any((u) => u['email'] == email)) {
      throw Exception("User already exists");
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final name = email.split('@')[0];
    
    await _userBox.put(id, {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'avatar': '',
    });

    await login(email, password);
  }

  Future<void> logout() async {
    await _settingsBox.delete('current_user');
    _currentUser = null;
    _controller.add(null);
  }

  Future<void> updateProfile({required String uid, String? name, String? avatar}) async {
    final userMap = _userBox.get(uid);
    if (userMap != null) {
      if (name != null) userMap['name'] = name;
      if (avatar != null) userMap['avatar'] = avatar;
      
      await _userBox.put(uid, userMap);

      _currentUser = _currentUser?.copyWith(name: name, avatar: avatar);
      await _settingsBox.put('current_user', {
        'id': _currentUser!.id,
        'email': _currentUser!.email,
        'name': _currentUser!.name,
        'avatar': _currentUser!.avatar,
      });
      _controller.add(_currentUser);
    }
  }
}
