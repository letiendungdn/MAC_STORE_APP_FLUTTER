import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mac_store_app/controllers/category_controllers.dart';
import 'package:mac_store_app/controllers/subcategory_controller.dart';
import 'package:mac_store_app/models/category.dart';
import 'package:mac_store_app/models/subcategory.dart';
import 'package:mac_store_app/views/screens/nav_screens/widgets/header_widget.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  // A future that will hold the list  of categories once loaded from the Api
  late Future<List<Category>> futureCategory;
  Category? _selectedCategory;
  List<Subcategory> _subcategories = [];
  final SubcategoryController _subcategoryController = SubcategoryController();

  @override
  void initState() {
    super.initState();
    futureCategory = CategoryController().loadCategories();
    // once the categories are loaded proccess then
    futureCategory.then((categories) {
      // iterate through the categories to find the  "Fashion " category
      for (var category in categories) {
        if (category.name == "Fashion") {
          // if "Fashion " category is found , set it as the selected category
          setState(() {
            _selectedCategory = category;
          });
          // load subcategories for the "Fashion" category
          _loadSubcategories(category.name);
        }
      }
    });
  }

  // this will load subcategories base on the categoryName
  Future<void> _loadSubcategories(String categoryName) async {
    final subcategories = await _subcategoryController
        .getSubCategoriesByCategoryName(categoryName);
    setState(() {
      _subcategories = subcategories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 20),
        child: const HeaderWidget(),
      ),
      body: Row(
        children: [
          // left size - Display categories
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey.shade200,
              child: FutureBuilder(
                future: futureCategory,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final categories = snapshot.data!;
                    return ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return ListTile(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                            _loadSubcategories(category.name);
                          },
                          title: Text(
                            category.name,
                            style: GoogleFonts.quicksand(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: _selectedCategory == category
                                  ? Colors.blue
                                  : Colors.black,
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
          // Right side - Display selected category details
          Expanded(
            flex: 5,
            child: _selectedCategory != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _selectedCategory!.name,
                          style: GoogleFonts.quicksand(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.7,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(_selectedCategory!.banner),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      _subcategories.isNotEmpty
                          ? GridView.builder(
                              shrinkWrap: true,
                              itemCount: _subcategories.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 4,
                                    crossAxisSpacing: 8,
                                  ),
                              itemBuilder: (context, index) {
                                final subcategory = _subcategories[index];
                                return Column(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                      ),
                                      child: Center(
                                        child: Image.network(
                                          subcategory.image,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        subcategory.subCategoryName,
                                        style: GoogleFonts.quicksand(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'No Sub categories',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                    ],
                  )
                : Container(),
          ),
        ],
      ),
    );
  }
}
