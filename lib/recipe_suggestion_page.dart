import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'recipe_details_page.dart';

import 'api_config.dart';

class RecipeSuggestionPage extends StatefulWidget {
  final List<String> availableIngredients;

  RecipeSuggestionPage({required this.availableIngredients});

  @override
  _RecipeSuggestionPageState createState() => _RecipeSuggestionPageState();
}

class _RecipeSuggestionPageState extends State<RecipeSuggestionPage> {
  List<dynamic> _recipeSuggestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecipeSuggestions();
  }

  Future<void> _fetchRecipeSuggestions() async {
    String apiUrl =
        '${ApiConfig.baseUrl}/api/recipe-by-ingredients?ingredients=${widget.availableIngredients.join(',')}';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          _recipeSuggestions = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load recipe suggestions');
      }
    } catch (e) {
      print('Error fetching recipe suggestions: $e');
      // Handle error fetching recipe suggestions
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Suggestions'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _recipeSuggestions.isEmpty
              ? Center(
                  child: Text('No recipe suggestions available.'),
                )
              : ListView.builder(
                  itemCount: _recipeSuggestions.length,
                  itemBuilder: (context, index) {
                    final recipe = _recipeSuggestions[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeDetailPage(
                              recipe: recipe,
                            ),
                          ),
                        );
                      },
                      child: RecipeCard(
                        recipe: recipe,
                      ),
                    );
                  },
                ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final dynamic recipe;

  RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            recipe['image'],
            fit: BoxFit.cover,
            height: 200,
            width: double.infinity,
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe['title'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Used Ingredients: ${recipe['usedIngredientCount']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Missing Ingredients: ${recipe['missedIngredientCount']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RecipeDetailPage extends StatelessWidget {
  final dynamic recipe;

  RecipeDetailPage({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Detail'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height / 3,
                    width: double.infinity,
                    child: Image.network(
                      recipe['image'],
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe['title'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Missing Ingredients:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 5),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: recipe['missedIngredients'].length,
                          itemBuilder: (context, index) {
                            final missedIngredient =
                                recipe['missedIngredients'][index];
                            return IngredientCard(
                              ingredient: missedIngredient,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                navigateToRecipeDetails(context, recipe['id']);
              },
              child: Text('More Details'),
            ),
          ),
        ],
      ),
    );
  }

  void navigateToRecipeDetails(BuildContext context, int recipeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailsPage(recipeId: recipeId),
      ),
    );
  }
}

class IngredientCard extends StatefulWidget {
  final dynamic ingredient;

  IngredientCard({required this.ingredient});

  @override
  _IngredientCardState createState() => _IngredientCardState();
}

class _IngredientCardState extends State<IngredientCard> {
  bool _isAddedToCart = false;

  void addToShopping(BuildContext context) {
    if (!_isAddedToCart) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String imageName = widget.ingredient['image'].split('/').last;
        CollectionReference shoppingCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('shopping');

        shoppingCollection
            .where('name', isEqualTo: widget.ingredient['name'])
            .where('quantity', isEqualTo: widget.ingredient['amount'])
            .get()
            .then((QuerySnapshot querySnapshot) {
          if (querySnapshot.size == 0) {
            shoppingCollection.add({
              'name': widget.ingredient['name'],
              'quantity': widget.ingredient['amount'],
              'timestamp': FieldValue.serverTimestamp(),
              'image': imageName,
            });
            setState(() {
              _isAddedToCart = true;
            });
            // Show the green animation
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Item added to shopping cart.'),
                duration: Duration(seconds: 2),
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () {
                    // Implement undo functionality if needed
                  },
                ),
              ),
            );
            // Reset the added to cart state after a delay
            Future.delayed(Duration(seconds: 2), () {
              setState(() {
                _isAddedToCart = false;
              });
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Item already exists in the shopping cart.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }).catchError((error) {
          print('Error adding to shopping cart: $error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred. Please try again later.'),
              duration: Duration(seconds: 2),
            ),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isAddedToCart ? null : () => addToShopping(context),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        color: _isAddedToCart ? Colors.lightGreen : Colors.white,
        child: Card(
          child: ListTile(
            leading: Image.network(
              widget.ingredient['image'],
              height: 50,
              width: 50,
              fit: BoxFit.cover,
            ),
            title: Text(widget.ingredient['name']),
            subtitle: Text(
                '${widget.ingredient['amount']} ${widget.ingredient['unit']}'),
            trailing: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                addToShopping(context);
              },
            ),
          ),
        ),
      ),
    );
  }
}
