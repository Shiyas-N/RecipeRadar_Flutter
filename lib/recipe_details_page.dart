import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecipeDetailsPage extends StatelessWidget {
  final int recipeId;

  RecipeDetailsPage({required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Details'),
      ),
      body: FutureBuilder(
        future: fetchRecipeDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            Map<String, dynamic> recipeDetails =
                snapshot.data as Map<String, dynamic>;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height / 3,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(recipeDetails['image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      recipeDetails['title'],
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Add other details and sections here, e.g., list of ingredients
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Ingredients:',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Display list of ingredients
                  for (var ingredient in recipeDetails['extendedIngredients'])
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('- ${ingredient['original']}'),
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> fetchRecipeDetails() async {
    final response = await http
        .get(Uri.parse('http://localhost:8080/api/recipe-details/$recipeId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load recipe details');
    }
  }
}
