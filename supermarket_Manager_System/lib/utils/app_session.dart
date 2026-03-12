import 'package:flutter/foundation.dart';

class AppSession extends ChangeNotifier {
  AppSession._();

  static final AppSession instance = AppSession._();

  int? _userId;
  String _fullName = '';
  String _role = '';

  int? get userId => _userId;
  String get fullName => _fullName;
  String get role => _role;
  bool get isLoggedIn => _userId != null;

  void setLogin({
    required int userId,
    required String fullName,
    required String role,
  }) {
    _userId = userId;
    _fullName = fullName;
    _role = role;
    notifyListeners();
  }

  void clear() {
    _userId = null;
    _fullName = '';
    _role = '';
    notifyListeners();
  }
}

