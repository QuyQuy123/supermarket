import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supermarket_manager_system/domain/models/customer_list_item.dart';
import 'package:supermarket_manager_system/utils/api_constants.dart';

class CustomerApiService {
  Future<List<CustomerListItem>> getCustomers() async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.customersPath}',
    );
    final response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load customers');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Invalid customers response format');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(CustomerListItem.fromJson)
        .toList();
  }

  Future<CustomerListItem> updateCustomer({
    required int customerId,
    required String phone,
    required double totalAmount,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.customersPath}/$customerId',
    );
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'totalAmount': totalAmount}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.body.isNotEmpty) {
        throw Exception(response.body);
      }
      throw Exception('Failed to update customer');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid update customer response format');
    }
    return CustomerListItem.fromJson(decoded);
  }

  Future<CustomerListItem> createCustomer({
    required String name,
    required String phone,
    required double totalAmount,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.customersPath}',
    );
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'phone': phone,
        'totalAmount': totalAmount,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.body.isNotEmpty) {
        throw Exception(response.body);
      }
      throw Exception('Failed to create customer');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid create customer response format');
    }
    return CustomerListItem.fromJson(decoded);
  }
}
