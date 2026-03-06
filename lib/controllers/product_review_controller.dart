import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mac_store_app/global_variables.dart';
import 'package:mac_store_app/models/product_review.dart';
import 'package:mac_store_app/services/manage_http_response.dart';

class ProductReviewController {
  Future<void> uploadReview({
    required BuildContext context,
    required String buyerId,
    required String email,
    required String fullName,
    required String productId,
    required double rating,
    required String review,
  }) async {
    try {
      final ProductReview productReview = ProductReview(
        id: '',
        buyerId: buyerId,
        email: email,
        fullName: fullName,
        productId: productId,
        rating: rating,
        review: review,
      );

      final http.Response response = await http.post(
        Uri.parse('$uri/api/product-review'),
        body: productReview.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (!context.mounted) return;

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () async {
          if (!context.mounted) return;
          showSnackBar(context, 'You have added a review');
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      showSnackBar(context, e.toString());
    }
  }
}
