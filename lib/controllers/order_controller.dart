import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mac_store_app/global_variables.dart';
import 'package:mac_store_app/models/order.dart';
import 'package:mac_store_app/services/manage_http_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderController {
  //function to upload orders
  Future<void> uploadOrders({
    required String id,
    required String fullName,
    required String email,
    required String state,
    required String city,
    required String locality,
    required String productName,
    required String productId,
    required int productPrice,
    required int quantity,
    required String category,
    required String image,
    required String buyerId,
    required String vendorId,
    required bool processing,
    required bool delivered,
    required String paymentStatus,
    required String paymentIntentId,
    required String paymentMethod,
    required BuildContext context,
  }) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? token = preferences.getString('auth_token');
      final Order order = Order(
        id: id,
        fullName: fullName,
        email: email,
        state: state,
        city: city,
        locality: locality,
        productName: productName,
        productId: productId,
        productPrice: productPrice,
        quantity: quantity,
        category: category,
        image: image,
        buyerId: buyerId,
        vendorId: vendorId,
        processing: processing,
        delivered: delivered,
        paymentStatus: paymentStatus,
        paymentIntentId: paymentIntentId,
        paymentMethod: paymentMethod,
      );

      http.Response response = await http.post(
        Uri.parse("$uri/api/orders"),
        body: order.toJson(),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
          "x-auth-token": token!,
        },
      );
      if (!context.mounted) return;
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () async {
          if (!context.mounted) return;
          showSnackBar(context, 'You have placed an order');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // Method to GET Orders by buyer id
  Future<List<Order>> loadOrders({required String buyerId}) async {
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/orders/$buyerId'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<Order> orders = data
            .map((order) => Order.fromJson(order as Map<String, dynamic>))
            .toList();
        return orders;
      } else {
        throw Exception('Failed to load Orders');
      }
    } catch (e) {
      throw Exception('Error loading Orders');
    }
  }

  //delete order by ID
  Future<void> deleteOrder({
    required String id,
    required BuildContext context,
  }) async {
    try {
      //send an HTTP Delete request to delete the order by _id
      http.Response response = await http.delete(
        Uri.parse('$uri/api/orders/$id'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );
      if (!context.mounted) return;

      //handle the HTTP Response
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () async {
          if (!context.mounted) return;
          showSnackBar(context, 'Order Deleted successfully');
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      showSnackBar(context, e.toString());
    }
  }

  //Method to count delivered orders
  Future<int> getDeliveredOrderCount({required String buyerId}) async {
    try {
      //load all order
      List<Order> orders = await loadOrders(buyerId: buyerId);
      //Filter ony delivered orders
      int deliveredCount = orders.where((order) => order.delivered).length;

      return deliveredCount;
    } catch (e) {
      throw Exception('Error counting Delivered Orders');
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent({
    required int amount,
    required String currency,
  }) async {
    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final String? token = preferences.getString('auth_token');

      final http.Response response = await http.post(
        Uri.parse('$uri/api/payment-intent'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token!,
        },
        body: jsonEncode(<String, dynamic>{
          'amount': amount,
          'currency': currency,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create payment intent');
      }
    } catch (e) {
      throw Exception('Error creating payment intent: $e');
    }
  }

  // Retrieve payment intent to know if the payment was successful or not
  Future<Map<String, dynamic>> getPaymentIntentStatus({
    required BuildContext context,
    required String paymentIntentId,
  }) async {
    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final String? token = preferences.getString('auth_token');

      final http.Response response = await http.get(
        Uri.parse('$uri/api/payment-intent/$paymentIntentId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token!,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get payment intent ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get payment intent $e');
    }
  }
}
