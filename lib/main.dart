import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add.dart';
import 'categories.dart';
import 'manage_categories.dart';

const String addr = "192.168.1.58";

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
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Color(0xFF806491)),
        scaffoldBackgroundColor: Color(0xFF806491),
        textTheme: TextTheme(
          displayLarge: TextStyle(
              fontFamily: 'Fira Sans',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black),
          bodyLarge: TextStyle(fontFamily: 'Numans', fontSize: 16, color: Colors.black),
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> topItems = [];
  List<dynamic> searchResults = [];
  List<dynamic> allItems = [];

@override
void initState() {
  super.initState();
  fetchTopRatedItems();
  fetchAllItems();
}

  Future<void> fetchTopRatedItems() async {
    try {
      final response = await http.get(Uri.parse('http://$addr:3000/top-rated'));
      // debugPrint("Return status : ${response.statusCode}");
      if (response.statusCode == 200 && response.body != null) {
        setState(() {
          // debugPrint(response.body);
          topItems = json.decode(response.body);
        });
      } else {
        debugPrint("Fetch top item response : ${json.decode(response.body)}");
        throw Exception('Failed to load top-rated items');
      }
    } catch (error) {
      debugPrint('Error $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading top-rated items: $error')),
      );
    }
  }

  Future<void> fetchAllItems() async {
    try {
      final response = await http.get(Uri.parse('http://$addr:3000/items'));
      // debugPrint("RESPONSE : ${response.body}");
      if (response.statusCode == 200 && response.body != null) {
        final items = json.decode(response.body);
        // debugPrint("TEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEST");
        setState(() {
          allItems = items
            ..sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));  // Ensure both are strings
        });
      } else {
        throw Exception('Failed to load all items');
      }
    } catch (error) {
      // debugPrint("ERROR STATEMENT : ${error}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading all items: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hobs", style: Theme.of(context).textTheme.displayLarge),
        backgroundColor: Color(0xFF2F70AF),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(onResults: (results) {
              setState(() {
                searchResults = results;
              });
            }),
          ),

          // Top 5 Items Section
          if (topItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Top 5 Items", style: Theme.of(context).textTheme.displayLarge),
            ),
          if (topItems.isNotEmpty)
            SizedBox(
              height: 250,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.8),
                itemCount: topItems.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TopItemCard(item: topItems[index]),
                  );
                },
              ),
            ),

          // Search Results Section
          if (searchResults.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Search Results", style: Theme.of(context).textTheme.displayLarge),
            ),
          if (searchResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final item = searchResults[index];
                  return ListTile(
                    title: Text(item['name']),
                    subtitle: Text(item['description']),
                    trailing: Text("Rating: ${item['rating']}"),
                  );
                },
              ),
            ),

          if (searchResults.isEmpty && allItems.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: allItems.length,
                itemBuilder: (context, index) {
                  final item = allItems[index];
                  return ListTile(
                    title: Text(item['name']),
                    subtitle: Text(item['description']),
                    trailing: Text("Rating: ${item['rating'].toStringAsFixed(1)}"),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => RateItemDialog(
                          itemId: item['id'],
                          itemName: item['name'],
                          onRatingSubmitted: (newRating) {
                            setState(() {
                              item['rating'] = newRating;
                            });
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color(0xFF806491),
        unselectedItemColor: Colors.grey,
        currentIndex: 0, // Set the default selected tab
        onTap: (index) {
          if (index == 1) {
            // Navigate to Categories
            Navigator.push(context, MaterialPageRoute(builder: (context) => CategoriesScreen()));
          } else if (index == 2) {
            // Navigate to Add Item
            Navigator.push(context, MaterialPageRoute(builder: (context) => AddItemScreen()));
          } else if (index == 3) {
            // Navigate to Manage Categories
            Navigator.push(context, MaterialPageRoute(builder: (context) => ManageCategoriesScreen()));
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categories'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add Item'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Manage Categories'),
        ],
      ),
    );
  }
}

class TopItemCard extends StatelessWidget {
  final dynamic item;

  TopItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8),
      color: Color(0xFFB9848C),
      child: Container(
        width: 200,
        height: 250,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: () {
                debugPrint('http://$addr:3000${item['image']}'); // Debug print the image URL
                return item['image'] != null
                    ? Image.network(
                        'http://$addr:3000${item['image']}',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Center(child: Text('No Image'));
              }(),
            ),
            // Expanded(
            //   child: item['image'] != null
            //       ? Image.network(
            //           'http://$addr${item['image']}',
            //           fit: BoxFit.cover,
            //           width: double.infinity,
            //         )
            //       : Center(child: Text('No Image')),
            // ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    item['name'],
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Rating: ${item['rating'].toStringAsFixed(1)}",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchBar extends StatefulWidget {
  final Function(List<dynamic>) onResults;

  SearchBar({required this.onResults});

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      widget.onResults([]);
      return;
    }

    try {
      final response = await http.get(Uri.parse('http://$addr:3000/search?query=$query'));
      if (response.statusCode == 200) {
        final results = json.decode(response.body);
        widget.onResults(results);
      } else {
        throw Exception('Failed to search');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error performing search: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _performSearch,
      decoration: InputDecoration(
        hintText: "Search for a leisure activity...",
        hintStyle: TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(Icons.search, color: Color(0xFF2F70AF)),
      ),
    );
  }
}

class RateItemDialog extends StatefulWidget {
  final int itemId;
  final String itemName;
  final Function(double) onRatingSubmitted;

  RateItemDialog({required this.itemId, required this.itemName, required this.onRatingSubmitted});

  @override
  _RateItemDialogState createState() => _RateItemDialogState();
}

class _RateItemDialogState extends State<RateItemDialog> {
  double userRating = 0.0;

  Future<void> submitRating() async {
    try {
      final response = await http.post(
        Uri.parse('http://$addr:3000/update-rating'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "id": widget.itemId,
          "userRating": userRating,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rating submitted successfully!')),
        );
        widget.onRatingSubmitted(data['newRating']);
        Navigator.of(context).pop();
      } else {
        debugPrint(response.body);
        throw Exception('Failed to submit rating');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting rating: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Rate ${widget.itemName}"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Select your rating:"),
          Slider(
            value: userRating,
            min: 0,
            max: 5,
            divisions: 10,
            label: userRating.toString(),
            onChanged: (value) => setState(() => userRating = value),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text("Submit"),
          onPressed: () {
            if (userRating > 0) {
              submitRating();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please select a rating before submitting.')),
              );
            }
          },
        ),
      ],
    );
  }
}