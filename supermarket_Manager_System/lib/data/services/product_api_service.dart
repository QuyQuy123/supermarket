import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supermarket_manager_system/domain/models/product_list_item.dart';
import 'package:supermarket_manager_system/utils/api_constants.dart';

class ProductApiService {
  Future<List<ProductListItem>> getProducts() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.productsPath}');
    final response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load products');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Invalid products response format');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(ProductListItem.fromJson)
        .toList();
  }
}

