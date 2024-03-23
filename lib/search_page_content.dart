import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'recipe_details_page.dart';

import 'api_config.dart';

class SearchPageContent extends StatefulWidget {
  const SearchPageContent({Key? key}) : super(key: key);

  @override
  _SearchPageContentState createState() => _SearchPageContentState();
}

class _SearchPageContentState extends State<SearchPageContent> {
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];

  void _fetchSearchResults(String query) async {
    if (query.length < 3) {
      return;
    }

    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/api/recipes/search?query=$query'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> results = jsonResponse['results'];
      setState(() {
        _searchResults = results;
      });
    } else {
      throw Exception('Failed to load search results');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Search Recipes",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  //use expanded if you are using textformfield in row
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade400,
                                blurRadius: 10,
                                spreadRadius: 3,
                                offset: const Offset(5, 5))
                          ]),
                      child: TextFormField(
                        controller: _searchController,
                        onChanged: (value) {
                          _fetchSearchResults(value);
                        },
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search here...',
                            prefixIcon: Icon(Icons.search)),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),

                  Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade400,
                                blurRadius: 10,
                                spreadRadius: 3,
                                offset: const Offset(5, 5))
                          ]),
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(
                          Icons.sort,
                          size: 26,
                        ),
                      ))
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    if (_searchResults.isNotEmpty &&
                        index < _searchResults.length) {
                      final recipe = _searchResults[index];
                      final int recipeId = recipe['id'];
                      final String recipeTitle = recipe['title'];
                      final String recipeImageUrl = recipe['image'];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RecipeDetailsPage(recipeId: recipeId),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 4,
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            leading: recipeImageUrl != null
                                ? Image.network(
                                    recipeImageUrl,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                : SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: Center(child: Text('No Image')),
                                  ),
                            title: Text(recipeTitle),
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
