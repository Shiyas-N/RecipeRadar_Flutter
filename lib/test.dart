import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'recipe_suggestion_page.dart';

class ShoppingCartPageContent extends StatefulWidget {
  @override
  _ShoppingCartPageContentState createState() =>
      _ShoppingCartPageContentState();
}

class _ShoppingCartPageContentState extends State<ShoppingCartPageContent> {
  List<Map<String, dynamic>>? ingredientsData;
  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  final TextEditingController _newQuantityController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _selectedUnit = '';
  final List<String> _units = ['', 'kg', 'g', 'l', 'ml', 'piece'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/shopping.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            top: 200,
            left: 40,
            child: Text(
              'Shopping',
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: 75,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.shade400,
                        blurRadius: 10,
                        spreadRadius: 3,
                        offset: const Offset(5, 5))
                  ]),
              child: TextFormField(
                // controller: _searchController,
                onChanged: (value) {
                  // _fetchSearchResults(value);
                },
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search here...',
                    prefixIcon: Icon(Icons.search)),
              ),
            ),
          ),
          Positioned(
            top: 250,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(top: 5, left: 15, right: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: _auth.currentUser != null
                  ? _buildIngredientList(context)
                  : _buildNotAuthenticatedView(context),
            ),
          ),
          Positioned(
            top: 180,
            right: 30,
            child: FloatingActionButton(
              onPressed: () {
                _showAddDialog(context);
              },
              backgroundColor: Colors.blue,
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
          .collection('shopping')
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
          .collection('shopping')
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
    Map<String, dynamic>? _selectedIngredient; // Declare _selectedIngredient
    bool _showAdditionalFields =
        false; // Variable to control the visibility of additional fields
    bool? _notifyExpiry; // Define _notifyExpiry
    bool? _addToCart; // Define _addToCart

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: Text(
                'Add Ingredient',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Autocomplete<Map<String, dynamic>>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<Map<String, dynamic>>.empty();
                        }
                        return _fetchIngredients(context)
                            .then((List<Map<String, dynamic>> ingredients) {
                          return ingredients
                              .where((ingredient) => ingredient['name']
                                  .toLowerCase()
                                  .contains(
                                      textEditingValue.text.toLowerCase()))
                              .toList();
                        });
                      },
                      onSelected: (Map<String, dynamic> selectedIngredient) {
                        _ingredientController.text = selectedIngredient['name'];
                        setState(() {
                          _selectedIngredient = selectedIngredient;
                          _showAdditionalFields = true;
                        });
                      },
                      optionsMaxHeight: 200,
                      displayStringForOption: (option) => option['name'],
                    ),
                    SizedBox(height: 20),
                    if (_showAdditionalFields &&
                        _selectedIngredient != null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey[200],
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: TextField(
                                keyboardType: TextInputType.number,
                                controller: _quantityController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Quantity',
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          DropdownButton<String>(
                            value: _selectedUnit,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedUnit = newValue!;
                              });
                            },
                            items: [
                              DropdownMenuItem<String>(
                                value: '',
                                child: Text(
                                  'Select Unit',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              ...(_selectedIngredient?['all_units'] as List)
                                  .map((unit) {
                                return DropdownMenuItem<String>(
                                  value: unit.toString(),
                                  child: Text(unit.toString()),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _clearDialogValues();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_selectedIngredient != null) {
                      Navigator.pop(context);
                      await _addIngredient(context);
                      _clearDialogValues();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please select an ingredient.'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                  ),
                  child: Text('Add', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _clearDialogValues() {
    _ingredientController.clear();
    _quantityController.clear();
    _selectedUnit = '';
  }

  Future<List<Map<String, dynamic>>> _fetchIngredients(
      BuildContext context) async {
    String jsonString = await DefaultAssetBundle.of(context)
        .loadString('assets/ingredient3.json');
    List<dynamic> data = json.decode(jsonString);
    ingredientsData = data.cast<Map<String, dynamic>>().toList();
    return ingredientsData ?? [];
  }

  Future<void> _addIngredient(BuildContext context) async {
    User? user = _auth.currentUser;
    if (user != null) {
      final existingIngredients = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('shopping')
          .where('name', isEqualTo: _ingredientController.text)
          .get();

      if (existingIngredients.docs.isEmpty) {
        Map<String, dynamic>? selectedIngredient = ingredientsData!.firstWhere(
          (ingredient) => ingredient['name'] == _ingredientController.text,
          // orElse: () => null,
        );

        if (selectedIngredient != null) {
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('shopping')
              .add({
            'name': selectedIngredient['name'],
            'quantity': _quantityController.text,
            'timestamp': FieldValue.serverTimestamp(),
            'image': selectedIngredient['image'],
            'unit': _selectedUnit,
          });

          _ingredientController.clear();
          _quantityController.clear();
        }
      } else {
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
          .collection('shopping')
          .doc(ingredientId)
          .delete();
    }
  }
}
