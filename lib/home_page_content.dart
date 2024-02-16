import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'recipe_details_page.dart'; // Import the other file

class HomePageContent extends StatefulWidget {
  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  List<Map<String, dynamic>> recipes = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('http://localhost:8080/api/random-recipes?number=5'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      setState(() {
        recipes = List<Map<String, dynamic>>.from(
          data['recipes'].map((recipe) {
            return {
              'id': recipe['id'],
              'name': recipe['title'],
              'image': recipe['image'],
            };
          }),
        );
      });
    } else {
      print('Error: ${response.statusCode}');
      // Handle error
    }
  }

  void navigateToRecipeDetails(int recipeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailsPage(recipeId: recipeId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 4,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(recipes[index]['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      navigateToRecipeDetails(recipes[index]['id']);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    recipes[index]['name'],
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
