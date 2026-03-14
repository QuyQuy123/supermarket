import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supermarket_manager_system/domain/models/order_detail.dart';
import 'package:supermarket_manager_system/domain/models/order_list_item.dart';
import 'package:supermarket_manager_system/utils/api_constants.dart';

class OrderApiService {
  Future<List<OrderListItem>> getOrders() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.ordersPath}');
    final response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load orders');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Invalid orders response format');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(OrderListItem.fromJson)
        .toList();
  }

  Future<OrderDetail> getOrderDetail(int orderId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.ordersPath}/$orderId');
    final response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load order detail');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid order detail response format');
    }
    return OrderDetail.fromJson(decoded);
  }
}

