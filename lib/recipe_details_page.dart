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
    try {
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
    } catch (e) {
      print('Error fetching recipe details: $e');
      // Handle error
    }
  }

  Widget _buildRecipeImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(); // Placeholder or default image
    }

    return Image.network(
      imageUrl,
      width: double.infinity,
      height: 500,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(); // Placeholder or default image
      },
    );
  }

  Widget _buildIngredientImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(); // Placeholder or default image
    }

    String url = 'https://spoonacular.com/cdn/ingredients_100x100/${imageUrl}';

    return Image.network(
      url,
      width: 100,
      height: 100,
      fit: BoxFit.fill,
      errorBuilder: (context, error, stackTrace) {
        return Container(); // Placeholder or default image
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (recipeDetails == null)
                Center(child: CircularProgressIndicator())
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: '${widget.recipeId}-image',
                      child: _buildRecipeImage(recipeDetails!['image']),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16),
                          Text(
                            recipeDetails!['title'],
                            style: TextStyle(fontSize: 24),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.access_time),
                              SizedBox(width: 8),
                              Text(
                                'Ready in ${recipeDetails!['readyInMinutes']} minutes',
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Ingredients:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          // Create cards for each ingredient
                          ...List.generate(
                            recipeDetails!['extendedIngredients'].length,
                            (index) {
                              var ingredient =
                                  recipeDetails!['extendedIngredients'][index];
                              return Card(
                                child: ListTile(
                                  leading: SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: _buildIngredientImage(
                                        ingredient['image']),
                                  ),
                                  title: Text(ingredient['name']),
                                  subtitle: Text(
                                      '${ingredient['measures']['metric']['amount']} ${ingredient['measures']['metric']['unitShort']}'),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 16),
                          SizedBox(height: 50), // Add some free space
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(top: 16.0, left: 16.0),
        child: ClipOval(
          child: Material(
            color: const Color.fromARGB(255, 0, 0, 0),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: SizedBox(
                width: 48,
                height: 48,
                child: Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
      persistentFooterButtons: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SizedBox(
            width: double.infinity,
            child: FloatingActionButton.extended(
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
              label: Text(
                'Start Cooking',
                style: TextStyle(color: Colors.white),
              ),
              icon: Icon(Icons.local_dining, color: Colors.white),
              backgroundColor: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
