import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'recipe_instruction_page.dart';
import 'api_config.dart';

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
          '${ApiConfig.baseUrl}/api/recipe-details/${widget.recipeId}'));

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

  Future<Widget?> checkIngredientMatch(Map<String, dynamic> ingredient) async {
    try {
      // Fetch the ingredient from the Firestore collection
      String ingredientName = ingredient['name'];
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
        return IconButton(
          icon: Icon(Icons.add_shopping_cart),
          onPressed: () {
            addToCart(ingredient); // Call the addToShoppingList function
          },
        );
      }
    } catch (e) {
      print('Error checking ingredient match: $e');
      return null; // Error occurred
    }
  }

  void addToCart(Map<String, dynamic> ingredient) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String imageName = ingredient['image'].split('/').last;
        CollectionReference shoppingCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('shopping');

        QuerySnapshot querySnapshot = await shoppingCollection
            .where('name', isEqualTo: ingredient['name'])
            .where('quantity', isEqualTo: ingredient['amount'])
            .get();

        if (querySnapshot.size == 0) {
          // Item does not exist, add it to the shopping list
          await shoppingCollection.add({
            'name': ingredient['name'],
            'quantity': ingredient['amount'],
            'timestamp': FieldValue.serverTimestamp(),
            'image': imageName,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Item added to shopping list'),
            ),
          );
        } else {
          // Item exists, prompt user to add to existing quantity
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Item already exists in shopping list'),
                content: Text('Do you want to add to the existing quantity?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () async {
                      // Add to existing quantity
                      DocumentSnapshot doc = querySnapshot.docs.first;
                      int existingQuantity = doc['quantity'];
                      await doc.reference.update({
                        'quantity': existingQuantity + ingredient['amount'],
                      });
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Quantity updated'),
                        ),
                      );
                    },
                    child: Text('Yes'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('No'),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      print('Error adding to shopping cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again later.'),
        ),
      );
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
          future: checkIngredientMatch(ingredient),
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
