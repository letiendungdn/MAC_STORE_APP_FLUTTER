import 'package:flutter_riverpod/legacy.dart';
import 'package:mac_store_app/models/favorite.dart';

final favoriteProvider =
    StateNotifierProvider<FavoriteNotifier, Map<String, Favorite>>((ref) {
      return FavoriteNotifier();
    }); // StateNotifierProvider

class FavoriteNotifier extends StateNotifier<Map<String, Favorite>> {
  FavoriteNotifier() : super({});

  void addProductToFavorite({
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
    state[productId] = Favorite(
      productName: productName,
      productPrice: productPrice,
      category: category,
      image: image,
      vendorId: vendorId,
      productQuantity: productQuantity,
      quantity: quantity,
      productId: productId,
      description: description,
      fullName: fullName,
    );

    //notify listeners tha tthe state has changed
    state = {...state};
  }

  //Method to remove item from the cart
  void removeFavoriteItem(String productId) {
    state.remove(productId);
    //Notify Listeners that the state has changed

    state = {...state};
  }

  Map<String, Favorite> get getFavoriteItems => state;
}
