import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RefrigeratorPageContent extends StatefulWidget {
  @override
  _RefrigeratorPageContentState createState() =>
      _RefrigeratorPageContentState();
}

class _RefrigeratorPageContentState extends State<RefrigeratorPageContent> {
  List<Map<String, dynamic>>? ingredientsData;
  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //     // Your existing app bar content...
      //     ),
      body: Stack(
        children: [
          _auth.currentUser != null
              ? _buildIngredientList(context)
              : _buildNotAuthenticatedView(context),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () {
                _showAddDialog(context);
              },
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientList(BuildContext context) {
    return StreamBuilder(
      stream: _firestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('ingredients')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        List<DocumentSnapshot> ingredients = snapshot.data!.docs;

        return ListView.builder(
          itemCount: ingredients.length,
          itemBuilder: (context, index) {
            Map<String, dynamic>? ingredientData =
                ingredients[index].data() as Map<String, dynamic>?;

            return Card(
              child: ListTile(
                leading: SizedBox(
                  width: 100,
                  height: 100,
                  child: _buildIngredientImage(ingredientData?['image']),
                ),
                title: Text(ingredientData?['name'] ?? ''),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quantity: ${ingredientData?['quantity'] ?? 'N/A'}'),
                    Text(
                        'Added on: ${_formatTimestamp(ingredientData?['timestamp'])}'),
                    Text(
                        'Days to expire: ${_calculateDaysToExpire(ingredientData?['timestamp'])}'),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteIngredient(ingredients[index].id);
                  },
                ),
              ),
            );
          },
        );
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

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'N/A';
    }
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  int _calculateDaysToExpire(Timestamp? timestamp) {
    if (timestamp == null) {
      return 0;
    }

    DateTime addedDate = timestamp.toDate();

    // Calculate the due date (7 days after the added date)
    DateTime dueDate = addedDate.add(Duration(days: 7));

    DateTime currentDate = DateTime.now();
    Duration difference = dueDate.difference(currentDate);

    // Return the number of days until the due date
    return difference.inDays;
  }

  Widget _buildNotAuthenticatedView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'You are not authenticated.',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // Navigate to the authentication page (e.g., login page)
            },
            child: Text('Log In'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder(
          future: _fetchIngredients(context),
          builder:
              (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error fetching ingredients'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No ingredients available'));
            } else {
              return AlertDialog(
                title: Text('Add Ingredient'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Autocomplete<Map<String, dynamic>>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<Map<String, dynamic>>.empty();
                        }
                        return snapshot.data!
                            .where((ingredient) => ingredient['name']
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase()))
                            .toList();
                      },
                      onSelected: (Map<String, dynamic> selectedIngredient) {
                        _ingredientController.text = selectedIngredient['name'];
                      },
                      optionsMaxHeight: 200,
                      displayStringForOption: (option) => option['name'],
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        hintText: 'Enter quantity',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await _addIngredient(context);
                      Navigator.pop(context);
                    },
                    child: Text('Add'),
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchIngredients(
      BuildContext context) async {
    String jsonString = await DefaultAssetBundle.of(context)
        .loadString('assets/ingredients.json');
    List<dynamic> data = json.decode(jsonString);
    ingredientsData = data.cast<Map<String, dynamic>>().toList();
    return ingredientsData ??
        []; // Use an empty list if ingredientsData is null
  }

  Future<void> _addIngredient(BuildContext context) async {
    User? user = _auth.currentUser;
    if (user != null) {
      final existingIngredients = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('ingredients')
          .where('name', isEqualTo: _ingredientController.text)
          .get();

      if (existingIngredients.docs.isEmpty) {
        // Find the selected ingredient in the ingredients data
        Map<String, dynamic>? selectedIngredient = ingredientsData!.firstWhere(
          (ingredient) => ingredient['name'] == _ingredientController.text,
          // orElse: () => null,
        );

        if (selectedIngredient != null) {
          // If the ingredient is not already in the list, add it with the quantity
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('ingredients')
              .add({
            'name': selectedIngredient['name'],
            'quantity': _quantityController.text, // Use the quantity field
            'timestamp': FieldValue.serverTimestamp(),
            'image': selectedIngredient['image'], // Use the correct image name
          });

          _ingredientController.clear();
          _quantityController.clear();
        }
      } else {
        // If the ingredient is already in the list, show a warning
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Warning'),
              content: Text('The ingredient is already on the list.'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _deleteIngredient(String ingredientId) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('ingredients')
          .doc(ingredientId)
          .delete();
    }
  }
}
