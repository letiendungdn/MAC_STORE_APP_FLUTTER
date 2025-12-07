import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mac_store_app/global_variables.dart';
import 'package:mac_store_app/models/subcategory.dart';

class SubcategoryController {
  Future<List<Subcategory>> getSubCategoriesByCategoryName(
    String categoryName,
  ) async {
    try {
      // send an http get request to load the categories
      http.Response response = await http.get(
        Uri.parse("$uri/api/category/$categoryName/subcategories"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      debugPrint(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          return data
              .map((subcategory) => Subcategory.fromJson(subcategory))
              .toList();
        } else {
          debugPrint('subcategories not found');
          return [];
        }
      } else if (response.statusCode == 404) {
        debugPrint("subcategories not found");
        return [];
      } else {
        debugPrint("subcategories not found");
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching Categories $e');
      return [];
    }
  }
}
