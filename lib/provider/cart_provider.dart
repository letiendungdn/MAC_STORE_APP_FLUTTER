
import 'package:flutter_riverpod/legacy.dart';
import 'package:mac_store_app/models/cart.dart';

//Define a StateNotifierProvider to expose an instance of the CartNofier
//Making it accessible within our app
final cartProvider = StateNotifierProvider<CartNotifier, Map<String, Cart>>((
  ref,
) {
  return CartNotifier();
});

// Manages cart items keyed by productId.
class CartNotifier extends StateNotifier<Map<String, Cart>> {
  CartNotifier() : super({});

  void addProductToCart({
    required String productName,
    required int productPrice,
    required String category,
    required List<String> image,
    required String vendorId,
    required int productQuantity,
    required int quantity,
    required String productId,
    required String description,
    required String fullName,
  }) {
    // if the product is already in the cart, update its quantity
    final existingItem = state[productId];
    if (existingItem != null) {
      final updatedQuantity = (existingItem.quantity + quantity)
          .clamp(1, existingItem.productQuantity)
          .toInt();
      state = {
        ...state,
        productId: Cart(
          productName: existingItem.productName,
          productPrice: existingItem.productPrice,
          category: existingItem.category,
          image: existingItem.image,
          vendorId: existingItem.vendorId,
          productQuantity: existingItem.productQuantity,
          quantity: updatedQuantity,
          productId: existingItem.productId,
          description: existingItem.description,
          fullName: existingItem.fullName,
        ),
      };
      return;
    }

    // if the product is not in the cart, add it with the provided details
    state = {
      ...state,
      productId: Cart(
        productName: productName,
        productPrice: productPrice,
        category: category,
        image: image,
        vendorId: vendorId,
        productQuantity: productQuantity,
        quantity: quantity.clamp(1, productQuantity).toInt(),
        productId: productId,
        description: description,
        fullName: fullName,
      ),
    };
  }

  // Method to increment the quantity of a product in the cart
  void incrementCartItem(String productId) {
    final item = state[productId];
    if (item == null) return;

    if (item.quantity < item.productQuantity) {
      item.quantity++;
      // Notify listeners that the state has changed
      state = {...state};
    }
  }

  // Method to decrement the quantity of a product in the cart
  void decrementCartItem(String productId) {
    final item = state[productId];
    if (item == null) return;

    if (item.quantity > 1) {
      item.quantity--;
      state = {...state};
      return;
    }

    removeCartItem(productId);
  }

  // Method to remove item from the cart
  void removeCartItem(String productId) {
    if (!state.containsKey(productId)) return;
    final updated = {...state}..remove(productId);
    state = updated;
  }

  // Method to calculate total amount of items in the cart
  double calculateTotalAmount() {
    double totalAmount = 0.0;
    state.forEach((_, cartItem) {
      totalAmount += cartItem.quantity * cartItem.productPrice;
    });
    return totalAmount;
  }
}
