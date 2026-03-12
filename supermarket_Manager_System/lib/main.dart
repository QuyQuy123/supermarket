import 'package:flutter/material.dart';
import 'package:supermarket_manager_system/presentation/pages/login_page.dart';

void main() {
  runApp(const SupermarketManagerApp());
}

class SupermarketManagerApp extends StatelessWidget {
  const SupermarketManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Supermarket Manager',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Segoe UI',
      ),
      home: const LoginPage(),
    );
  }
}
