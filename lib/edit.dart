import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String addr = "192.168.1.58";

class EditItemScreen extends StatefulWidget {
  final dynamic item;

  EditItemScreen({required this.item});

  @override
  _EditItemScreenState createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String description;
  late double rating;

  @override
  void initState() {
    super.initState();
    name = widget.item['name'];
    description = widget.item['description'];
    rating = widget.item['rating'];
  }

  Future<void> updateItem() async {
    try {
      final response = await http.put(
        Uri.parse('http://$addr:3000/update-item/${widget.item['id']}'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "name": name,
          "description": description,
          "rating": rating,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item updated successfully')),
        );
        Navigator.of(context).pop(true); // Return success
      } else {
        throw Exception('Failed to update item');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating item: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Item"),
        backgroundColor: Color(0xFF2F70AF),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(labelText: "Name"),
                onChanged: (value) => name = value,
                validator: (value) => value!.isEmpty ? "Name is required" : null,
              ),
              TextFormField(
                initialValue: description,
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
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    updateItem();
                  }
                },
                child: Text("Update Item"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}