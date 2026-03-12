import 'package:flutter/material.dart';

class RoleHomePage extends StatelessWidget {
  const RoleHomePage({
    super.key,
    required this.role,
    required this.fullName,
  });

  final String role;
  final String fullName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(
        child: Text(
          'Welcome ${fullName.isEmpty ? 'User' : fullName}\nRole: $role',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
