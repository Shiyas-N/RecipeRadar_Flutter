import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'recipe_details_page.dart';
import 'api_config.dart';

class HomePageContent extends StatefulWidget {
  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  List<Map<String, dynamic>> recipes = [];
  bool isLoading = true; // Track whether data is loading or not

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response =
        await http.get(Uri.parse('${ApiConfig.baseUrl}/api/five-recipes'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      setState(() {
        recipes = List<Map<String, dynamic>>.from(
          data['recipes'].map((recipe) {
            return {
              'id': recipe['id'],
              'name': recipe['title'],
              'image': recipe['image'],
              'readyInMinutes': recipe['readyInMinutes'],
            };
          }),
        );
        isLoading = false; // Data fetching is complete
      });
    } else {
      print('Error: ${response.statusCode}');
      isLoading = false; // Data fetching failed
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
    return isLoading
        ? Center(
            child:
                CircularProgressIndicator(), // Display circular progress indicator while loading
          )
        : ListView.builder(
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
                        Stack(
                          alignment: Alignment.topRight,
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
                            IconButton(
                              icon: Icon(Icons.favorite_border),
                              onPressed: () {},
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time),
                                  SizedBox(width: 4),
                                  Text(
                                    '${recipes[index]['readyInMinutes']} min',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ],
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
                      ],
                    ),
                  ));
            },
          );
  }
}
