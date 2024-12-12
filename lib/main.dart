import 'package:flutter/material.dart';
import 'models/item.dart';
import 'models/category.dart';
import 'services/api_service.dart';
import 'views/add_item_view.dart';
import 'views/category_list_view.dart';

const String addr = "127.0.0.1";

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF2F70AF),
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: Color(0xFF806491)),
        scaffoldBackgroundColor: Color(0xFF806491),
        textTheme: TextTheme(
          displayLarge: TextStyle(
              fontFamily: 'Fira Sans',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white),
          bodyLarge: TextStyle(
              fontFamily: 'Numans', fontSize: 16, color: Colors.black),
        ),
      ),
      home: ItemListView(),
    );
  }
}

class ItemListView extends StatefulWidget {
  @override
  _ItemListViewState createState() => _ItemListViewState();
}

class _ItemListViewState extends State<ItemListView> {
  List<Item> items = [];
  List<Category> categories = [];
  List<Item> topRatedItems = [];
  List<Item> filteredItems = [];
  String filter = 'Nom'; // Default sorting filter
  bool isLoading = true;
  String searchQuery = ''; // Track search input
  String? selectedCategory; // Selected category for filtering

  @override
  void initState() {
    super.initState();
    fetchAllItems();
    fetchTopRatedItems();
    fetchCategories();
  }

  Future<void> fetchAllItems() async {
    try {
      final fetchedItems = await ApiService.fetchItems();
      setState(() {
        items = fetchedItems;
        filteredItems = fetchedItems; // Initialize filtered items
        isLoading = false;
      });
      print("Fetched items: ${items.length}");
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching items: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des éléments : $e')),
      );
    }
  }

  Future<void> fetchTopRatedItems() async {
    try {
      final fetchedTopRated = await ApiService.fetchTopRated();
      setState(() {
        topRatedItems = fetchedTopRated;
      });
      print("Fetched top-rated items: ${topRatedItems.length}");
    } catch (e) {
      print("Error fetching top-rated items: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des tendances : $e')),
      );
    }
  }

  Future<void> fetchCategories() async {
    try {
      final fetchedCategories = await ApiService.fetchCategories();
      setState(() {
        categories = fetchedCategories;
      });
      print("Fetched categories: ${categories.map((c) => c.name).toList()}");
    } catch (e) {
      print("Error fetching categories: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors du chargement des catégories : $e')),
      );
    }
  }

  void filterItems(String query) {
    setState(() {
      searchQuery = query; // Update search query
    });

    final filtered = items.where((item) {
      final itemName = item.name.toLowerCase();
      final input = query.toLowerCase();
      return itemName.contains(input);
    }).toList();

    setState(() {
      filteredItems = filtered;
    });
    print("Filtered items count: ${filteredItems.length}");
  }

  void applySorting(String filter) {
    setState(() {
      this.filter = filter;
      if (filter == 'Nom') {
        filteredItems.sort((a, b) => a.name.compareTo(b.name));
      } else if (filter == 'Note') {
        filteredItems.sort((a, b) => b.rating.compareTo(a.rating));
      }
    });
    print("Applied sorting: $filter");
  }

  void applyCategoryFilter(String? categoryName) {
    if (categoryName == null || categoryName.isEmpty) {
      setState(() {
        selectedCategory = null;
        filteredItems = items; // Show all items if no category is selected
      });
      print("Cleared category filter, showing all items.");
      return;
    }

    setState(() {
      selectedCategory = categoryName;
      filteredItems = items
          .where((item) =>
              item.category?.toLowerCase() == categoryName.toLowerCase())
          .toList();
    });
    print(
        "Filtered items by category: $categoryName, count: ${filteredItems.length}");
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(170), // Custom AppBar height
        child: AppBar(
          backgroundColor: Color(0xFF2F70AF),
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and sort dropdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Hobs",
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    DropdownButton<String>(
                      value: filter,
                      icon: Icon(Icons.filter_list, color: Colors.white),
                      dropdownColor: Color(0xFF2F70AF),
                      items: ['Nom', 'Note']
                          .map((value) => DropdownMenuItem(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) applySorting(value);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // Search bar
                TextField(
                  onChanged: filterItems,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Recherche...',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    prefixIcon: Icon(Icons.search, color: Colors.white70),
                  ),
                ),
                SizedBox(height: 8),
                // Category dropdown
                DropdownButton<String>(
                  value: selectedCategory,
                  hint: Text("Filtrer par catégorie",
                      style: TextStyle(color: Colors.white)),
                  icon: Icon(Icons.category, color: Colors.white),
                  dropdownColor: Color(0xFF2F70AF),
                  isExpanded: true,
                  items: categories
                      .map((category) => DropdownMenuItem(
                            value: category.name,
                            child: Text(
                              category.name,
                              style: TextStyle(color: Colors.white),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) => applyCategoryFilter(value),
                ),
              ],
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Show top 5 only when search query is empty
                if (searchQuery.isEmpty &&
                    selectedCategory == null &&
                    topRatedItems.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Top 5 Tendances",
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                if (searchQuery.isEmpty &&
                    selectedCategory == null &&
                    topRatedItems.isNotEmpty)
                  Container(
                    height: 250, // Fixed height for horizontal list
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: topRatedItems.length,
                      itemBuilder: (context, index) {
                        final item = topRatedItems[index];
                        return Container(
                          width: screenWidth * 0.6, // Responsive card width
                          margin: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Card(
                            color: Color(0xFFB9848C),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Responsive image
                                  item.image != null
                                      ? Center(
                                          child: Image.network(
                                            'http://${addr}:3000${item.image}',
                                            width: double.infinity,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 80,
                                            color: Colors.grey,
                                          ),
                                        ),
                                  SizedBox(height: 8),
                                  // Display item name
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  // Display rating
                                  Text(
                                    'Note : ${item.rating.toStringAsFixed(1)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                // Display filtered items
                if (filteredItems.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Pas d\'éléments trouvés',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ...filteredItems.map((item) {
                  return Card(
                    color: Color(0xFFB9848C),
                    margin: EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: screenWidth * 0.05,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Responsive image
                          item.image != null
                              ? Center(
                                  child: Image.network(
                                    'http://${addr}:3000${item.image}',
                                    width: screenWidth * 0.9,
                                    height: screenWidth * 0.5,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: screenWidth * 0.25,
                                    color: Colors.grey,
                                  ),
                                ),
                          SizedBox(height: 16),
                          Text(
                            item.name,
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            item.description,
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Note : ${item.rating.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color(0xFF806491),
        unselectedItemColor: Colors.grey,
        currentIndex: 0, // Default selected tab
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CategoryListView()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddItemView()),
            ).then((_) => fetchAllItems());
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(
              icon: Icon(Icons.category), label: 'Catégories'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Ajouter'),
        ],
      ),
    );
  }
}
