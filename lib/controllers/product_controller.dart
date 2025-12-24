import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mac_store_app/global_variables.dart';
import 'package:mac_store_app/models/product.dart';

class ProductController {
  Future<List<Product>> loadPopularProducts() async {
    try {
      http.Response response = await http.get(
        Uri.parse("$uri/api/popular-products"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      debugPrint(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        final List<Product> products = data
            .map((product) => Product.fromJson(product as Map<String, dynamic>))
            .toList();
        return products;
      } else {
        throw Exception('Failed to load popular products');
      }
    } catch (e) {
      throw Exception('Error loading popular products: $e');
    }
  }
}
