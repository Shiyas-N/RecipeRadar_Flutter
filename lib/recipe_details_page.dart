import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'recipe_instruction_page.dart';

class RecipeDetailsPage extends StatefulWidget {
  final int recipeId;

  RecipeDetailsPage({Key? key, required this.recipeId}) : super(key: key);

  @override
  _RecipeDetailsPageState createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage> {
  Map<String, dynamic>? recipeDetails;

  @override
  void initState() {
    super.initState();
    fetchRecipeDetails();
  }

  Future<void> fetchRecipeDetails() async {
    final response = await http.get(Uri.parse(
        'http://localhost:8080/api/recipe-details/${widget.recipeId}'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      setState(() {
        recipeDetails = data;
      });
    } else {
      print('Error: ${response.statusCode}');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Details'),
      ),
      body: recipeDetails == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.network(
                    recipeDetails!['image'],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 16),
                  Text(
                    recipeDetails!['title'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  if (recipeDetails!['extendedIngredients'] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ingredients:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        for (var ingredient
                            in recipeDetails!['extendedIngredients'])
                          Text('- ${ingredient['original']}'),
                        SizedBox(height: 16),
                      ],
                    ),
                  // Display other recipe details here using recipeDetails
                  // Example: Text('Servings: ${recipeDetails!['servings']}'),
                  // Example: Text('Ready in minutes: ${recipeDetails!['readyInMinutes']}'),
                  // Add other widgets for displaying details

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeInstructionPage(
                            recipeId: widget.recipeId,
                          ),
                        ),
                      );
                    },
                    child: Text('Start Cooking'),
                  ),
                ],
              ),
            ),
    );
  }
}
