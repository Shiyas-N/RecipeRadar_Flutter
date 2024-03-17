import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class ShoppingCartPageContent extends StatefulWidget {
  @override
  _ShoppingCartPageContentState createState() =>
      _ShoppingCartPageContentState();
}

class _ShoppingCartPageContentState extends State<ShoppingCartPageContent> {
  List<Map<String, dynamic>>? shoppingData;
  final TextEditingController _itemController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _auth.currentUser != null
          ? _buildShoppingList(context)
          : _buildNotAuthenticatedView(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildShoppingList(BuildContext context) {
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

        List<DocumentSnapshot> shoppingItems = snapshot.data!.docs;

        return ListView.builder(
          itemCount: shoppingItems.length,
          itemBuilder: (context, index) {
            Map<String, dynamic>? shoppingItemData =
                shoppingItems[index].data() as Map<String, dynamic>?;

            return Card(
              child: ListTile(
                title: Text(shoppingItemData?['name'] ?? ''),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteShoppingItem(shoppingItems[index].id);
                  },
                ),
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
        return AlertDialog(
          title: Text('Add Item'),
          content: TextField(
            controller: _itemController,
            decoration: InputDecoration(
              labelText: 'Item Name',
              hintText: 'Enter item name',
            ),
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
                await _addItem(context);
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addItem(BuildContext context) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('shopping')
          .add({
        'name': _itemController.text,
        // Add additional fields if needed
      });

      _itemController.clear();
    }
  }

  Future<void> _deleteShoppingItem(String itemId) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('shopping')
          .doc(itemId)
          .delete();
    }
  }
}
