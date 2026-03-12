import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supermarket_manager_system/domain/models/login_result.dart';
import 'package:supermarket_manager_system/utils/api_constants.dart';

class AuthApiService {
  Future<LoginResult> login({
    required String emailOrUsername,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginPath}');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': emailOrUsername,
        'password': password,
      }),
    );

    if (response.body.isEmpty) {
      throw Exception('Empty server response');
    }

    final Map<String, dynamic> json = jsonDecode(response.body);
    final result = LoginResult.fromJson(json);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return result;
    }

    throw Exception(result.message);
  }
}
