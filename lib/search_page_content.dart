import 'package:flutter/material.dart';
import 'recipe.dart'; // Add this line to import the recipe.dart file

class SearchPageContent extends StatefulWidget {
  final List<Recipe> recipeData; // Add recipeData as a parameter

  SearchPageContent(
      {required this.recipeData}); // Add constructor to receive recipeData

  @override
  _SearchPageContentState createState() => _SearchPageContentState();
}

class _SearchPageContentState extends State<SearchPageContent> {
  TextEditingController _searchController = TextEditingController();
  List<Recipe> _searchResults = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSearchField(),
          const SizedBox(height: 16.0),
          _buildSearchResults(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search for recipes...',
        suffixIcon: IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            _performSearch();
          },
        ),
      ),
    );
  }

  void _performSearch() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _searchResults = widget.recipeData
          .where((recipe) => recipe.title.toLowerCase().contains(query))
          .toList();
    });
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Text('No results found.');
    } else {
      return Expanded(
        child: ListView.builder(
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            Recipe recipe = _searchResults[index];
            return ListTile(
              title: Text(recipe.title),
              // Add more details or actions as needed
            );
          },
        ),
      );
    }
  }
}
