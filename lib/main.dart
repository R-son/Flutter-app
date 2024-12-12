import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add.dart';
import 'categories.dart';
<<<<<<< HEAD
import 'manage_categories.dart';
=======
import 'package:flutter_dotenv/flutter_dotenv.dart';
>>>>>>> main

String? addr = dotenv.env['URL'];

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF2F70AF),
<<<<<<< HEAD
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Color(0xFF806491)),
        scaffoldBackgroundColor: Color(0xFF806491),
=======
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: Color(0xFF806491)),
>>>>>>> main
        textTheme: TextTheme(
          displayLarge: TextStyle(
              fontFamily: 'Fira Sans',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black),
          bodyLarge: TextStyle(
              fontFamily: 'Numans', fontSize: 16, color: Colors.black),
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
      if (response.statusCode == 200 && response.body != null) {
        final items = json.decode(response.body);
        setState(() {
          allItems = items..sort((a, b) => a['name'].compareTo(b['name']));
        });
      } else {
        throw Exception('Failed to load all items');
      }
    } catch (error) {
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
<<<<<<< HEAD
              child: Text("Top 5 Items", style: Theme.of(context).textTheme.displayLarge),
            ),
          if (topItems.isNotEmpty)
            SizedBox(
              height: 250,
=======
              child: Text("Top 5 Items",
                  style: Theme.of(context).textTheme.displayLarge),
            ),
          if (topItems.isNotEmpty)
            SizedBox(
              height: 250, // Fixed height for the PageView
>>>>>>> main
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
<<<<<<< HEAD
              child: Text("Search Results", style: Theme.of(context).textTheme.displayLarge),
=======
              child: Text("Search Results",
                  style: Theme.of(context).textTheme.displayLarge),
>>>>>>> main
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
<<<<<<< HEAD

          // All Items Section (Displayed if No Search Results)
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
            )

          if (searchResults.isEmpty && allItems.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: allItems.length,
                itemBuilder: (context, index) {
                  final item = allItems[index];
                  return ListTile(
                    title: Text(item['name']),
                    subtitle: Text(item['description']),
                    trailing: Text("Rating: ${item['rating']}"),
                  );
                },
              ),
            ),
        ],
      ),

=======
          if (topItems.isEmpty && searchResults.isEmpty)
            Expanded(child: Center(child: CircularProgressIndicator())),
        ],
      ),
>>>>>>> main
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color(0xFF806491),
        unselectedItemColor: Colors.grey,
        currentIndex: 0, // Set the default selected tab
        onTap: (index) {
          if (index == 1) {
            // Navigate to Categories
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => CategoriesScreen()));
          } else if (index == 2) {
            // Navigate to Add Item
<<<<<<< HEAD
            Navigator.push(context, MaterialPageRoute(builder: (context) => AddItemScreen()));
          } else if (index == 3) {
            // Navigate to Manage Categories
            Navigator.push(context, MaterialPageRoute(builder: (context) => ManageCategoriesScreen()));
=======
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AddItemScreen()));
>>>>>>> main
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.category), label: 'Categories'),
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
      final response =
          await http.get(Uri.parse('http://$addr:3000/search?query=$query'));
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
<<<<<<< HEAD
}
=======
}
>>>>>>> main
