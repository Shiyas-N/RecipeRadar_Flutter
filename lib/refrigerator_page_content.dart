import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'recipe_suggestion_page.dart';

class RefrigeratorPageContent extends StatefulWidget {
  @override
  _RefrigeratorPageContentState createState() =>
      _RefrigeratorPageContentState();
}

class _RefrigeratorPageContentState extends State<RefrigeratorPageContent> {
  List<Map<String, dynamic>>? ingredientsData;
  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _newQuantityController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _selectedUnit = 'kg';

  final List<String> _units = ['kg', 'g', 'L', 'mL', 'nos'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _auth.currentUser != null
              ? _buildIngredientList(context)
              : _buildNotAuthenticatedView(context),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              _showAddDialog(context);
            },
            child: Icon(Icons.add),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              _getRecipeSuggestions(context);
            },
            child: Icon(Icons.food_bank),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientList(BuildContext context) {
    return Expanded(
      child: StreamBuilder(
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
                    width: 75,
                    height: 75,
                    child: _buildIngredientImage(ingredientData?['image']),
                  ),
                  title: Text(ingredientData?['name'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _updateQuantity(
                              context,
                              ingredients[index].id,
                              ingredientData?['quantity'] ?? 0,
                              ingredientData?['unit']);
                        },
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.blue,
                          ),
                          child: Text(
                            'Quantity: ${ingredientData?['quantity'] ?? 'N/A'} ${ingredientData?['unit'] ?? ''}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
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
      ),
    );
  }

  void _updateQuantity(BuildContext context, String ingredientId,
      String currentQuantity, String? currentUnit) {
    TextEditingController _newQuantityController =
        TextEditingController(text: currentQuantity);
    double _quantity = double.tryParse(currentQuantity) ?? 0.0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Quantity'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _quantity -= 0.1; // Decrease by 0.1
                            _newQuantityController.text =
                                _formatQuantity(_quantity);
                          });
                        },
                        icon: Icon(Icons.remove),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _newQuantityController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(fontSize: 18),
                          decoration: InputDecoration(
                            labelText: 'New Quantity',
                            hintText: 'Enter new quantity',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _quantity = double.tryParse(value) ?? 0.0;
                            });
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _quantity += 0.1; // Increase by 0.1
                            _newQuantityController.text =
                                _formatQuantity(_quantity);
                          });
                        },
                        icon: Icon(Icons.add),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  if (currentUnit != null)
                    DropdownButton<String>(
                      value:
                          _selectedUnit, // Use _selectedUnit instead of currentUnit
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedUnit = newValue!; // Update _selectedUnit
                        });
                      },
                      items:
                          _units.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                String newQuantity = _newQuantityController.text;
                if (newQuantity.isNotEmpty) {
                  _updateIngredientQuantity(
                      ingredientId, newQuantity, _selectedUnit);
                  Navigator.pop(context); // Close the dialog
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  String _formatQuantity(double quantity) {
    return quantity.truncateToDouble() == quantity
        ? quantity.toInt().toString()
        : quantity.toStringAsFixed(1);
  }

  void _updateIngredientQuantity(
      String ingredientId, String newQuantity, String newUnit) {
    User? user = _auth.currentUser;
    if (user != null) {
      _firestore
          .collection('users')
          .doc(user.uid)
          .collection('ingredients')
          .doc(ingredientId)
          .update({'quantity': newQuantity, 'unit': newUnit});
    }
  }

  Widget _buildIngredientImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(); // Placeholder or default image
    }

    String url = 'https://spoonacular.com/cdn/ingredients_100x100/${imageUrl}';

    return Image.network(
      url,
      width: 50,
      height: 50,
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

  Future<void> _getRecipeSuggestions(BuildContext context) async {
    // Check if the user is authenticated
    if (_auth.currentUser == null) {
      // Show a message or navigate to the authentication page
      return;
    }

    // Fetch ingredients from Firestore
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('ingredients')
          .get();

      // Extract ingredient data from snapshot
      List<Map<String, dynamic>> ingredientsData = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // Check if there are any ingredients available
      if (ingredientsData.isEmpty) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('No Ingredients'),
              content:
                  Text('Please add ingredients to get recipe suggestions.'),
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
        return;
      }

      // Extract names of available ingredients
      List<String> availableIngredients = ingredientsData
          .map((ingredient) => ingredient['name'] as String)
          .toList();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecipeSuggestionPage(
            availableIngredients: availableIngredients,
          ),
        ),
      );
    } catch (e) {
      print('Error fetching ingredients: $e');
      // Handle error fetching ingredients
    }
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
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _quantityController,
                            decoration: InputDecoration(
                              labelText: 'Quantity',
                              hintText: 'Enter quantity',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _unitController,
                            decoration: InputDecoration(
                              labelText: 'Unit',
                              hintText: 'Enter unit',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
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
        .loadString('assets/ingredient3.json');
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
            'unit': _selectedUnit, // Use the selected unit
            'timestamp': FieldValue.serverTimestamp(),
            'image': selectedIngredient['image'],
            'expiry-days': selectedIngredient['expiry-days'],
            'threshold': selectedIngredient['threshold-quantity'],
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
