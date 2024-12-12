import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/category.dart';
import '../models/item.dart';
import '../services/api_service.dart';

class AddItemView extends StatefulWidget {
  @override
  _AddItemViewState createState() => _AddItemViewState();
}

class _AddItemViewState extends State<AddItemView> {
  final _formKey = GlobalKey<FormState>();
  List<Category> categories = [];
  String? selectedCategory;
  String name = '';
  String description = '';
  double rating = 0.0;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      categories = await ApiService.fetchCategories();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching categories: $e')),
      );
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> addItem() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Assuming your API supports multipart/form-data for file uploads
        await ApiService.addItem(
          Item(
            category: selectedCategory,
            name: name,
            description: description,
            rating: rating,
            image: selectedImage?.path, // Pass the image path
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item added successfully')),
        );
        Navigator.pop(context); // Navigate back after adding the item
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding item: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text("Add Item", style: Theme.of(context).textTheme.displayLarge),
        backgroundColor: Color(0xFF2F70AF),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown for categories
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories
                    .map((cat) => DropdownMenuItem(
                          value: cat.name,
                          child: Text(cat.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedCategory = value);
                },
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFFB9848C),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) =>
                    value == null ? 'Please select a category' : null,
              ),
              SizedBox(height: 16),
              // Name input
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFFB9848C),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) => name = value,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Name is required' : null,
              ),
              SizedBox(height: 16),
              // Description input
              TextFormField(
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFFB9848C),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) => description = value,
                validator: (value) => value == null || value.isEmpty
                    ? 'Description is required'
                    : null,
              ),
              SizedBox(height: 16),
              // Image picker
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Color(0xFFB9848C),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.white),
                  ),
                  child: selectedImage == null
                      ? Center(
                          child: Text(
                            'Tap to select an image',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.file(
                            selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 16),
              // Rating slider
              Text(
                "Rating: ${rating.toStringAsFixed(1)}",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Slider(
                value: rating,
                min: 0,
                max: 5,
                divisions: 10,
                onChanged: (value) => setState(() => rating = value),
              ),
              SizedBox(height: 16),
              // Submit button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2F70AF),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  onPressed: addItem,
                  child: Text("Add Item", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
