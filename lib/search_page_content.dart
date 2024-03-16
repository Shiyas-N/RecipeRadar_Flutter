import 'dart:convert';
import 'package:flutter/material.dart';
import 'recipe.dart'; // Add this line to import the recipe.dart file
import 'recipe_details_page.dart';

class SearchPageContent extends StatefulWidget {
  @override
  _SearchPageContentState createState() => _SearchPageContentState();
}

class _SearchPageContentState extends State<SearchPageContent> {
  TextEditingController _searchController = TextEditingController();
  List<Recipe> _recipeData = [];

  @override
  void initState() {
    super.initState();
    _loadRecipeData('assets/allrecipedata.json');
    _loadAnotherRecipeData('assets/recipedetails2.json');
  }

  Future<void> _loadRecipeData(String jsonFilePath) async {
    String jsonData =
        await DefaultAssetBundle.of(context).loadString(jsonFilePath);

    final Map<String, dynamic> jsonMap = json.decode(jsonData);
    List<dynamic> recipesJson = jsonMap['recipes'];

    List<Recipe> recipes =
        recipesJson.map((recipeJson) => Recipe.fromJson(recipeJson)).toList();

    // Avoid adding duplicate recipes based on unique identifier (e.g., id)
    for (Recipe newRecipe in recipes) {
      if (!_recipeData
          .any((existingRecipe) => existingRecipe.id == newRecipe.id)) {
        _recipeData.add(newRecipe);
      }
    }

    setState(() {}); // Trigger a rebuild after loading data
  }

  Future<void> _loadAnotherRecipeData(String jsonFilePath) async {
    String jsonData =
        await DefaultAssetBundle.of(context).loadString(jsonFilePath);

    final Map<String, dynamic> jsonMap = json.decode(jsonData);
    List<dynamic> recipesJson = jsonMap['recipes'];

    List<Recipe> anotherRecipeData =
        recipesJson.map((recipeJson) => Recipe.fromJson(recipeJson)).toList();

    // Avoid adding duplicate recipes based on unique identifier (e.g., id)
    for (Recipe newRecipe in anotherRecipeData) {
      if (!_recipeData
          .any((existingRecipe) => existingRecipe.id == newRecipe.id)) {
        _recipeData.add(newRecipe);
      }
    }

    setState(() {}); // Trigger a rebuild after loading data
  }

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
    List<Recipe> searchResults = _recipeData
        .where((recipe) => recipe.title.toLowerCase().contains(query))
        .toList();

    setState(() {
      _recipeData = searchResults;
    });
  }

  Widget _buildSearchResults() {
    if (_recipeData.isEmpty) {
      return Text('No results found.');
    } else {
      return Expanded(
        child: ListView.builder(
          itemCount: _recipeData.length,
          itemBuilder: (context, index) {
            Recipe recipe = _recipeData[index];
            return ListTile(
              title: Text(recipe.title),
              // Add more details or actions as needed
              onTap: () {
                _navigateToRecipeDetails(recipe.id); // Pass the recipe id
              },
            );
          },
        ),
      );
    }
  }

  void _navigateToRecipeDetails(int recipeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailsPage(recipeId: recipeId),
      ),
    );
  }
}
