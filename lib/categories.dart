import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String addr = "192.168.1.58";

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<dynamic> categories = [];
  List<dynamic> items = [];
  String? selectedCategory;

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
        throw Exception('Failed to load categories');
      }
    } catch (error) {
      setState(() {
        categories = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading categories: $error')),
      );
    }
  }

  Future<void> fetchItems(String category) async {
    try {
      final response = await http.get(Uri.parse('http://$addr:3000/items?category=$category'));
      if (response.statusCode == 200) {
        setState(() {
          items = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load items');
      }
    } catch (error) {
      setState(() {
        items = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading items: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Categories"),
        backgroundColor: Color(0xFF2F70AF),
      ),
      body: categories.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Select a Category:", style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: selectedCategory,
                    items: categories.map<DropdownMenuItem<String>>((category) {
                      return DropdownMenuItem<String>(
                        value: category['name'],
                        child: Text(category['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                        if (value != null) fetchItems(value);
                      });
                    },
                    hint: Text("Choose a category"),
                  ),
                  SizedBox(height: 20),
                  if (items.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(items[index]['name']),
                            subtitle: Text("Rating: ${items[index]['rating'].toStringAsFixed(1)}"),
                          );
                        },
                      ),
                    ),
                  if (items.isEmpty && selectedCategory != null)
                    Center(child: Text("No items found for the selected category.")),
                ],
              ),
            ),
    );
  }
}