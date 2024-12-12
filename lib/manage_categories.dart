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
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return ListTile(
            title: Text(category['name']),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                deleteCategory(category['id']);
              },
            ),
          );
        },
      ),
    );
  }
}
