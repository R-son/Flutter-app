import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String addr = "192.168.1.58";

class ManageCategoriesScreen extends StatefulWidget {
  @override
  _ManageCategoriesScreenState createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  List<dynamic> categories = [];
  final _categoryNameController = TextEditingController();
  final _updateCategoryNameController = TextEditingController();
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('http://$addr:3000/categories'));
      if (response.statusCode == 200) {
        setState(() {
          categories = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to fetch categories');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading categories: $error')),
      );
    }
  }

  Future<void> addCategory() async {
    final categoryName = _categoryNameController.text;

    if (categoryName.isEmpty) {
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://$addr:3000/add-category'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': categoryName}),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category added successfully')),
        );
        _categoryNameController.clear();
        fetchCategories();
      } else {
        throw Exception('Failed to add category');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding category: $error')),
      );
    }
  }

  Future<void> updateCategory() async {
    if (_selectedCategoryId == null || _updateCategoryNameController.text.isEmpty) {
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('http://$addr:3000/update-category/$_selectedCategoryId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': _updateCategoryNameController.text}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category updated successfully')),
        );
        _updateCategoryNameController.clear();
        _selectedCategoryId = null;
        fetchCategories();
      } else {
        throw Exception('Failed to update category');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating category: $error')),
      );
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    try {
      final response = await http.delete(Uri.parse('http://$addr:3000/delete-category/$categoryId'));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category deleted successfully')),
        );
        fetchCategories(); // Refresh the list
      } else {
        throw Exception('Failed to delete category');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting category: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Categories"),
        backgroundColor: Color(0xFF2F70AF),
      ),
      body: Column(
        children: [
          // Add Category Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _categoryNameController,
                    decoration: InputDecoration(hintText: 'Enter category name'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: addCategory,
                ),
              ],
            ),
          ),
          // Update Category Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _updateCategoryNameController,
                    decoration: InputDecoration(hintText: 'Enter new category name'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: updateCategory,
                ),
              ],
            ),
          ),
          // Category List
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ListTile(
                  title: Text(category['name']),
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = category['id'];
                      _updateCategoryNameController.text = category['name'];
                    });
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      deleteCategory(category['id']);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
