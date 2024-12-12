import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
<<<<<<< HEAD
import 'edit.dart';
=======
import 'package:flutter_dotenv/flutter_dotenv.dart';
>>>>>>> main

String? addr = dotenv.env['URL'];

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
      final response =
          await http.get(Uri.parse('http://$addr:3000/categories'));
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

  Future<void> fetchItems(String? category) async {
  try {
    final response = category == "All Categories"
        ? await http.get(Uri.parse('http://$addr:3000/items')) // Fetch all items
        : await http.get(Uri.parse('http://$addr:3000/items?category=$category')); // Fetch items for a specific category

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

  Future<void> deleteItem(int itemId) async {
    try {
<<<<<<< HEAD
      final response = await http.delete(Uri.parse('http://$addr:3000/delete-item/$itemId'));
=======
      final response = await http
          .get(Uri.parse('http://$addr:3000/items?category=$category'));
>>>>>>> main
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item deleted successfully')),
        );
        if (selectedCategory != null) {
          fetchItems(selectedCategory!); // Refresh the item list
        }
      } else {
        throw Exception('Failed to delete item');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting item: $error')),
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
                          final item = items[index];
                          return ListTile(
<<<<<<< HEAD
                            title: Text(item['name']),
                            subtitle: Text("Rating: ${item['rating'].toStringAsFixed(1)}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () async {
                                    final updated = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditItemScreen(item: item),
                                      ),
                                    );
                                    if (updated == true && selectedCategory != null) {
                                      fetchItems(selectedCategory!); // Refresh items after update
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Delete Item"),
                                          content: Text("Are you sure you want to delete '${item['name']}'?"),
                                          actions: [
                                            TextButton(
                                              child: Text("Cancel"),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: Text("Delete"),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                deleteItem(item['id']);
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
=======
                            title: Text(items[index]['name']),
                            subtitle: Text(
                                "Rating: ${items[index]['rating'].toStringAsFixed(1)}"),
>>>>>>> main
                          );
                        },
                      ),
                    ),
                  if (items.isEmpty && selectedCategory != null)
                    Center(
                        child:
                            Text("No items found for the selected category.")),
                ],
              ),
            ),
    );
  }
}
