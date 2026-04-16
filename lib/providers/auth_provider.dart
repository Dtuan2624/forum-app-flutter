import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';

// --- LỚP SERVICE (Xử lý API PHP) ---
class AuthService {
  final String baseUrl = "http://localhost/forum_api";

  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        body: {'email': email, 'password': password},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return UserModel.fromMap(data['user']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<UserModel?> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register.php'),
        body: {'name': name, 'email': email, 'password': password},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return UserModel.fromMap(data['user']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<UserModel?> updateProfile({required String uid, String? name, String? avatar}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update_user.php'),
        body: {'id': uid, 'name': name, 'avatar': avatar},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromMap(data['user']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

// --- LỚP PROVIDER (Quản lý Session & Trạng thái UI) ---
class AppAuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();
  UserModel? _user;
  bool _isLoading = true; // Luôn bắt đầu bằng true để kiểm tra session

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  AppAuthProvider() {
    _initSession();
  }

  // TỰ ĐỘNG NẠP SESSION KHI MỞ APP (ĐÃ SỬA)
  Future<void> _initSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userData = prefs.getString('user_session');

      if (userData != null) {
        // Chuyển chuỗi JSON từ máy thành đối tượng User
        _user = UserModel.fromMap(jsonDecode(userData));
      }
    } catch (e) {
      debugPrint("Lỗi khởi tạo session: $e");
    } finally {
      // QUAN TRỌNG: Phải tắt loading và báo cho App biết dù có user hay không
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final userResult = await _service.login(email, password);
    if (userResult != null) {
      _user = userResult;
      final prefs = await SharedPreferences.getInstance();
      // Lưu lại vào máy để lần sau không cần đăng nhập
      await prefs.setString('user_session', jsonEncode(_user!.toMap()));

      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final userResult = await _service.register(name, email, password);
    if (userResult != null) {
      _user = userResult;
      final prefs = await SharedPreferences.getInstance();
      // Sau khi đăng ký thành công, tự động lưu session đăng nhập luôn
      await prefs.setString('user_session', jsonEncode(_user!.toMap()));

      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_session'); // Xóa session khỏi máy
    _user = null;
    notifyListeners();
  }

  Future<void> updateProfile({String? name, String? avatar}) async {
    if (_user == null) return;
    final updatedUser = await _service.updateProfile(uid: _user!.id, name: name, avatar: avatar);
    if (updatedUser != null) {
      _user = updatedUser;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_session', jsonEncode(_user!.toMap()));
      notifyListeners();
    }
  }
}