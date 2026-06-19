//StatNotifier for delivered order count
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mac_store_app/controllers/order_controller.dart';
import 'package:mac_store_app/services/manage_http_response.dart';

class DeliveredOrderCountProvider extends StateNotifier<int> {
  DeliveredOrderCountProvider() : super(0);

  //Method to fetch Delivered Orders count
  Future<void> fetchDeliveredOrderCount(
    String buyerId,
    BuildContext context,
  ) async {
    try {
      OrderController orderController = OrderController();
      int count =
          await orderController.getDeliveredOrderCount(buyerId: buyerId);
      state = count; //Update the state with the count
    } catch (e) {
      if (!context.mounted) return;
      showSnackBar(context, 'Error Fetching Delivered order : $e');
    }
  }

  //Method to reset the count
  void resetCount() {
    state = 0;
  }
}

final deliveredOrderCountProvider =
    StateNotifierProvider<DeliveredOrderCountProvider, int>((ref) {
  return DeliveredOrderCountProvider();
}); // StateNotifierProvider
