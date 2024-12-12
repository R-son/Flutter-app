import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../models/category.dart';
import '../models/item.dart';

const String addr = "127.0.0.1";

class ApiService {
  static Future<List<Category>> fetchCategories() async {
    final response = await http.get(Uri.parse('http://$addr:3000/categories'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  static Future<void> addCategory(String categoryName) async {
    final response = await http.post(
      Uri.parse('http://$addr:3000/add-category'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': categoryName}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add category: ${response.body}');
    }
  }

  // Delete Category
  static Future<void> deleteCategory(int id) async {
    final response =
        await http.delete(Uri.parse('http://$addr:3000/delete-category/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete category');
    }
  }

  static Future<List<Item>> fetchItems({String? category}) async {
    final uri = category != null && category != "All Categories"
        ? Uri.parse('http://$addr:3000/items?category=$category')
        : Uri.parse('http://$addr:3000/items');

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load items');
    }
  }

  static Future<List<Item>> fetchTopRated() async {
    final response = await http.get(Uri.parse('http://$addr:3000/top-rated'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch top-rated items');
    }
  }

  static Future<void> deleteItem(int id) async {
    final response =
        await http.delete(Uri.parse('http://$addr:3000/delete-item/$id'));

    if (response.statusCode == 200) {
      print('Item deleted successfully.');
    } else {
      throw Exception('Failed to delete item: ${response.body}');
    }
  }

  static Future<void> addItem(Item item) async {
    try {
      print(item);
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://$addr:3000/add-item'),
      );

      // Add fields
      request.fields['name'] = item.name;
      request.fields['description'] = item.description;
      request.fields['rating'] = item.rating.toString();
      request.fields['category'] = item.category.toString();
      //log
      // Add image if it exists
      if (item.image != null && File(item.image!).existsSync()) {
        request.files.add(
          await http.MultipartFile.fromPath('image', item.image!),
        );
      }

      // Send request
      final response = await request.send();

      // Process response
      if (response.statusCode == 200) {
        print('Item added successfully.');
      } else {
        final responseBody = await response.stream.bytesToString();
        print('Error: $responseBody');
        throw Exception('Failed to add item: $responseBody');
      }
    } catch (e) {
      throw Exception('Error adding item: $e');
    }
  }
}
