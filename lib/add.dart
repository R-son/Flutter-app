import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

const String addr = "192.168.1.58";

class AddItemScreen extends StatefulWidget {
  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  String? category;
  String name = '';
  String description = '';
  double rating = 0.0;
  List<dynamic> categories = [];
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('http://${addr}:3000/categories'));
      if (response.statusCode == 200) {
        setState(() {
          categories = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading categories: $error')),
      );
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> addItem() async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://${addr}:3000/add-item'),
      );
      request.fields['category'] = category!;
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['rating'] = rating.toString();

      if (selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', selectedImage!.path),
        );
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item added successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add item')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Item"),
        backgroundColor: Color(0xFF2F70AF),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: "Category"),
                  value: category,
                  items: categories.map<DropdownMenuItem<String>>((dynamic category) {
                    return DropdownMenuItem<String>(
                      value: category['name'],
                      child: Text(category['name']),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => category = value),
                  validator: (value) => value == null || value.isEmpty ? "Category is required" : null,
                  hint: Text("Select a category"),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Name"),
                  onChanged: (value) => name = value,
                  validator: (value) => value!.isEmpty ? "Name is required" : null,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Description"),
                  onChanged: (value) => description = value,
                  validator: (value) => value!.isEmpty ? "Description is required" : null,
                ),
                Slider(
                  value: rating,
                  min: 0,
                  max: 5,
                  divisions: 10,
                  label: rating.toString(),
                  onChanged: (value) => setState(() => rating = value),
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: selectedImage == null
                        ? Center(child: Text("Tap to select an image"))
                        : Image.file(selectedImage!, fit: BoxFit.cover),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      addItem();
                    }
                  },
                  child: Text("Add Item"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}