import 'package:flutter/foundation.dart';

class AppSession extends ChangeNotifier {
  AppSession._();

  static final AppSession instance = AppSession._();

  int? _userId;
  int? _roleId;
  String _fullName = '';
  String _role = '';

  int? get userId => _userId;
  int? get roleId => _roleId;
  String get fullName => _fullName;
  String get role => _role;
  bool get isLoggedIn => _userId != null;

  void setLogin({
    required int userId,
    required int roleId,
    required String fullName,
    required String role,
  }) {
    _userId = userId;
    _roleId = roleId;
    _fullName = fullName;
    _role = role;
    notifyListeners();
  }

  void clear() {
    _userId = null;
    _roleId = null;
    _fullName = '';
    _role = '';
    notifyListeners();
  }
}

