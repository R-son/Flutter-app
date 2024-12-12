import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add.dart';
import 'categories.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: Color(0xFF806491)),
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

  @override
  void initState() {
    super.initState();
    fetchTopRatedItems();
  }

  Future<void> fetchTopRatedItems() async {
    try {
      final response = await http.get(Uri.parse('http://$addr:3000/top-rated'));
      debugPrint("Return status : ${response.statusCode}");
      if (response.statusCode == 200 && response.body != null) {
        setState(() {
          debugPrint(response.body);
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
              child: Text("Top 5 Items",
                  style: Theme.of(context).textTheme.displayLarge),
            ),
          if (topItems.isNotEmpty)
            SizedBox(
              height: 250, // Fixed height for the PageView
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
              child: Text("Search Results",
                  style: Theme.of(context).textTheme.displayLarge),
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
          if (topItems.isEmpty && searchResults.isEmpty)
            Expanded(child: Center(child: CircularProgressIndicator())),
        ],
      ),
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
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AddItemScreen()));
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.category), label: 'Categories'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add Item'),
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
        height: 200,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item['name'],
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 0.5),
              Text(
                "Rating: ${item['rating'].toStringAsFixed(1)}",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
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
}
