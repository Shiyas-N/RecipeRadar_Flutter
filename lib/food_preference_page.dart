import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';

class FoodPreferencesPage extends StatefulWidget {
  @override
  _FoodPreferencesPageState createState() => _FoodPreferencesPageState();
}

class _FoodPreferencesPageState extends State<FoodPreferencesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> _flavorProfiles = [];
  List<String> _cookingMethods = [];
  List<String> _dishTypes = [];
  List<String> _allergiesAndDislikes = [];
  List<String> _cuisinePreferences = [];
  List<String> _nutritionalPreferences = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 20),
            Text(
              'Tell us about your food preferences',
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
                letterSpacing: 1,
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 40),
            _buildSectionHeading('Flavor'),
            _buildMultiSelectFormField(
              options: ['Spicy', 'Savory', 'Sweet', 'Sour', 'Bitter'],
              selectedValues: _flavorProfiles,
              onChanged: (List<String> values) {
                setState(() {
                  _flavorProfiles = values;
                });
              },
            ),
            _buildSectionHeading('Preferred Cooking Methods'),
            _buildMultiSelectFormField(
              options: [
                'Grilling',
                'Baking',
                'Sautéing',
                'Steaming',
                'Roasting'
              ],
              selectedValues: _cookingMethods,
              onChanged: (List<String> values) {
                setState(() {
                  _cookingMethods = values;
                });
              },
            ),
            _buildSectionHeading('Dish Types'),
            _buildMultiSelectFormField(
              options: [
                'Main course',
                'Soup',
                'Salad',
                'Bread',
                'Drink',
                'Dessert',
                'Breakfast',
                'Side dish',
                'Snack',
                'Appetizer',
                'Sauce',
              ],
              selectedValues: _dishTypes,
              onChanged: (List<String> values) {
                setState(() {
                  _dishTypes = values;
                });
              },
            ),
            _buildSectionHeading('Allergies and Dislikes'),
            _buildMultiSelectFormField(
              options: [
                'Peanut',
                'Gluten',
                'Dairy',
                'Seafood',
                'Egg',
                'Soy',
                'Grain',
                'Shellfish',
                'Sulfite',
                'Wheat',
                'Sesame',
                'Tree Nut'
              ],
              selectedValues: _allergiesAndDislikes,
              onChanged: (List<String> values) {
                setState(() {
                  _allergiesAndDislikes = values;
                });
              },
            ),
            _buildSectionHeading('Cuisine Preferences'),
            _buildMultiSelectFormField(
              options: [
                'Italian',
                'African',
                'Asian',
                'American',
                'Mexican',
                'Chinese',
                'Indian',
                'European',
                'French',
                'German',
                'Greek',
                'Japanese',
                'Korean',
                'Spanish',
                'Mediterranean'
              ],
              selectedValues: _cuisinePreferences,
              onChanged: (List<String> values) {
                setState(() {
                  _cuisinePreferences = values;
                });
              },
            ),
            _buildSectionHeading('Nutritional Preferences'),
            _buildMultiSelectFormField(
              options: [
                'Gluten Free',
                'Ketogenic',
                'Vegetarian',
                'Lacto-Vegetarian',
                'Ovo-Vegetarian',
                'Vegan',
                'Pescetarian'
              ],
              selectedValues: _nutritionalPreferences,
              onChanged: (List<String> values) {
                setState(() {
                  _nutritionalPreferences = values;
                });
              },
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _savePreferences,
              child: Text(
                'Save Preferences',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeading(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildMultiSelectFormField({
    required List<String> options,
    required List<String> selectedValues,
    required Function(List<String>) onChanged,
  }) {
    return Wrap(
      spacing: 8,
      children: options.map((option) {
        bool isSelected = selectedValues.contains(option);
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (bool selected) {
            List<String> newSelectedValues = List.from(selectedValues);
            if (selected) {
              newSelectedValues.add(option);
            } else {
              newSelectedValues.remove(option);
            }
            onChanged(newSelectedValues);
          },
          selectedColor: Colors.lightGreenAccent,
        );
      }).toList(),
    );
  }

  void _savePreferences() async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('preference')
            .doc('user_preferences')
            .set({
          'flavorProfiles': _flavorProfiles,
          'cookingMethods': _cookingMethods,
          'type': _dishTypes,
          'intolerances': _allergiesAndDislikes,
          'cuisine': _cuisinePreferences,
          'diet': _nutritionalPreferences,
        });
        print('Preferences saved successfully!');
        _navigateToHomePage();
      } catch (error) {
        print('Error saving preferences: $error');
      }
    }
  }

  void _navigateToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => HomePage(userPreferences: {
                'flavorProfiles': _flavorProfiles,
                'cookingMethods': _cookingMethods,
                'dishTypes': _dishTypes,
                'allergiesAndDislikes': _allergiesAndDislikes,
                'cuisinePreferences': _cuisinePreferences,
                'nutritionalPreferences': _nutritionalPreferences,
              })),
    );
  }
}
