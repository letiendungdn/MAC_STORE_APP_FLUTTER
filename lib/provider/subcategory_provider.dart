import 'package:flutter_riverpod/legacy.dart';
import 'package:mac_store_app/models/subcategory.dart';

class SubcategoryProvider extends StateNotifier<List<Subcategory>> {
  SubcategoryProvider() : super([]);

  void setSubcategories(List<Subcategory> subcategories) {
    state = subcategories;
  }
}

final subcategoryProvider =
    StateNotifierProvider<SubcategoryProvider, List<Subcategory>>((ref) {
  return SubcategoryProvider();
});
