import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
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

  Future<Widget?> checkIngredientMatch(String ingredientName) async {
    try {
      // Fetch the ingredient from the Firestore collection
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('ingredients')
          .where('name', isEqualTo: ingredientName.toLowerCase())
          .limit(1)
          .get();

      // Check if the ingredient exists in Firestore
      if (snapshot.docs.isNotEmpty) {
        return null; // Ingredient found in Firestore
      } else {
        return Icon(Icons.add_shopping_cart);
      }
    } catch (e) {
      print('Error checking ingredient match: $e');
      return null; // Error occurred
    }
  }

  @override
  Widget build(BuildContext context) {
    if (recipeDetails == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    List<dynamic> ingredients = recipeDetails!['extendedIngredients'];
    List<Widget> shoppingItems = [];
    List<Widget> nonShoppingItems = [];

    for (var ingredient in ingredients) {
      String name = ingredient['name'].toLowerCase();
      List<String> strings = ['water', 'salt', 'sugar', 'pepper', 'sea salt'];
      if (strings.contains(name)) {
        nonShoppingItems.add(_buildNonShoppableIngredientCard(ingredient));
      } else {
        shoppingItems.add(_buildShoppableIngredientCard(ingredient));
      }
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildRecipeImage(recipeDetails!['image']),
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
                    ...shoppingItems,
                    SizedBox(height: 16),
                    ...nonShoppingItems,
                    SizedBox(height: 50),
                  ],
                ),
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

  Widget _buildShoppableIngredientCard(Map<String, dynamic> ingredient) {
    return Card(
      child: ListTile(
        leading: SizedBox(
          width: 100,
          height: 100,
          child: _buildIngredientImage(ingredient['image']),
        ),
        title: Text(ingredient['name']),
        subtitle: Text(
          '${ingredient['measures']['metric']['amount']} ${ingredient['measures']['metric']['unitShort']}',
        ),
        trailing: FutureBuilder<Widget?>(
          future: checkIngredientMatch(ingredient['name']),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Icon(Icons.error);
            } else {
              if (snapshot.data == null) {
                // If ingredient is found, return nothing
                return SizedBox.shrink();
              } else {
                // If ingredient is not found, return the shopping cart icon
                return snapshot.data!;
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildNonShoppableIngredientCard(Map<String, dynamic> ingredient) {
    return Card(
      child: ListTile(
        leading: SizedBox(
          width: 100,
          height: 100,
          child: _buildIngredientImage(ingredient['image']),
        ),
        title: Text(ingredient['name']),
        subtitle: Text(
          '${ingredient['measures']['metric']['amount']} ${ingredient['measures']['metric']['unitShort']}',
        ),
      ),
    );
  }
}
