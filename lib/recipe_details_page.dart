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

  Future<Widget> checkIngredientMatch(Map<String, dynamic> ingredient) async {
    User? user = _auth.currentUser;
    try {
      String ingredientName = ingredient['name'];
      double requiredQuantity = ingredient['measures']['metric']['amount'];
      String requiredUnit = ingredient['measures']['metric']['unitShort'];

      List<String> exceptions = [
        "asparagus",
        "spinach"
      ]; // Add more exceptions as needed

      List<String> nameVariations = [ingredientName.toLowerCase()];
      if (!exceptions.contains(ingredientName.toLowerCase()) &&
          ingredientName.endsWith('s')) {
        nameVariations.add(ingredientName
            .substring(0, ingredientName.length - 1)
            .toLowerCase());
        nameVariations.add(ingredientName
            .substring(0, ingredientName.length - 2)
            .toLowerCase()); // Handle "es" plural
      } else {
        nameVariations.add(ingredientName + 's');
      }
      for (String variation in nameVariations) {
        final QuerySnapshot snapshot = await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('ingredients')
            .where('name', isEqualTo: variation)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          // Ingredient found in Firestore, check quantity and unit
          var ingredientDoc = snapshot.docs.first;
          String? availableQuantityStr = ingredientDoc['quantity'] as String?;
          double? availableQuantity = availableQuantityStr != null
              ? double.tryParse(availableQuantityStr)
              : null;
          String? availableUnit = ingredientDoc['unit'] as String?;
          if (availableQuantity != null && availableUnit != null) {
            if (availableUnit == requiredUnit) {
              if (availableQuantity >= requiredQuantity) {
                return Container(); // Ingredient found and available quantity is sufficient
              } else {
                // Return IconButton if required quantity is greater than available quantity
                return IconButton(
                  icon: Icon(Icons.add_shopping_cart),
                  onPressed: () {
                    addToCart(
                        ingredient); // Call the addToShoppingList function
                  },
                );
              }
            } else {
              // Convert the required quantity to the available unit and compare
              double convertedQuantity = await convertQuantity(ingredientName,
                  requiredQuantity, requiredUnit, availableUnit);
              if (convertedQuantity <= availableQuantity) {
                return Container(); // Ingredient found and converted quantity is sufficient
              } else {
                // Return IconButton if required quantity is greater than available quantity
                return IconButton(
                  icon: Icon(Icons.add_shopping_cart),
                  onPressed: () {
                    addToCart(
                        ingredient); // Call the addToShoppingList function
                  },
                );
              }
            }
          }
        }
      }

      // If no match was found, return IconButton if required quantity is greater than 0
      if (requiredQuantity > 0) {
        return IconButton(
          icon: Icon(Icons.add_shopping_cart),
          onPressed: () {
            addToCart(ingredient); // Call the addToShoppingList function
          },
        );
      } else {
        return IconButton(
          icon: Icon(Icons.add_shopping_cart),
          onPressed: () {
            addToCart(ingredient); // Call the addToShoppingList function
          },
        );
        ; // No matched ingredient and no requirement for the ingredient
      }
    } catch (e) {
      print('Error checking ingredient match: $e');
      return Container(); // Error occurred
    }
  }

  Future<double> convertQuantity(String ingredientName, double sourceAmount,
      String sourceUnit, String targetUnit) async {
    try {
      String baseUrl = '${ApiConfig.baseUrl}/api/recipes/convert';
      String url =
          '$baseUrl?ingredientName=$ingredientName&sourceAmount=$sourceAmount&sourceUnit=$sourceUnit&targetUnit=$targetUnit';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return double.parse(response.body);
      } else {
        print('Failed to convert quantity: ${response.statusCode}');
        return sourceAmount;
      }
    } catch (e) {
      print('Error converting quantity: $e');
      return sourceAmount;
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
      List<String> strings = [
        'water',
        'salt',
        'sugar',
        'pepper',
        'sea salt',
        'seasoning',
        'combination of water',
        'additional granulated sugar'
      ];
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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 75,
              height: 75,
              child: _buildIngredientImage(ingredient['image']),
            ),
            Expanded(
              child: ListTile(
                title: Text(ingredient['name']),
                subtitle: Text(
                  '${ingredient['measures']['metric']['amount']} ${ingredient['measures']['metric']['unitShort']}',
                ),
              ),
            ),
            FutureBuilder<Widget?>(
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
          ],
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
