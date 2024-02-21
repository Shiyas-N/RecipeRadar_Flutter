import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RefrigeratorPageContent extends StatelessWidget {
  final TextEditingController _ingredientController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              _showAddDialog(context);
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _auth.currentUser != null
                ? _buildIngredientList(context)
                : _buildNotAuthenticatedView(context),
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
            return ListTile(
              title: Text(ingredients[index]['name']),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteIngredient(ingredients[index].id);
                },
              ),
            );
          },
        );
      },
    );
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
          future: _fetchIngredients(),
          builder: (context, AsyncSnapshot<List<String>> snapshot) {
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
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<String>.empty();
                        }
                        return snapshot.data!
                            .where((ingredient) => ingredient
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase()))
                            .toList();
                      },
                      onSelected: (String selectedIngredient) {
                        _ingredientController.text = selectedIngredient;
                      },
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

  Future<List<String>> _fetchIngredients() async {
    final response =
        await http.get(Uri.parse('http://localhost:8080/api/ingredients'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.cast<String>().toList();
    } else {
      throw Exception('Failed to fetch ingredients');
    }
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
        // If the ingredient is not already in the list, add it
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('ingredients')
            .add({
          'name': _ingredientController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });

        _ingredientController.clear();
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
