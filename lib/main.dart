import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'providers/auth_provider.dart';
import 'providers/post_provider.dart';
import 'providers/category_provider.dart';
import 'providers/comment_provider.dart';

import 'views/auth/login_screen.dart';
import 'views/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Hive
  await Hive.initFlutter();

  // 2. Open Boxes
  await Hive.openBox('users');
  await Hive.openBox('posts');
  await Hive.openBox('categories');
  await Hive.openBox('comments');
  await Hive.openBox('settings');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Forum App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const Root(), // Điểm bắt đầu là class Root bên dưới
      ),
    );
  }
}

class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy trạng thái từ AppAuthProvider
    final auth = Provider.of<AppAuthProvider>(context);

    // TRƯỜNG HỢP 1: Đang nạp dữ liệu từ bộ nhớ (Session)
    if (auth.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // TRƯỜNG HỢP 2: Đã nạp xong, kiểm tra xem có User hay không
    if (auth.isLoggedIn) {
      return const HomeScreen(); // Nếu có user -> vào thẳng Home
    } else {
      return const LoginScreen(); // Nếu chưa -> vào màn hình Login
    }
  }
} // Kết thúc class Root tại đây