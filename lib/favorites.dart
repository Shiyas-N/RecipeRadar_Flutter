import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import 'api_config.dart';
import 'recipe_details_page.dart';

class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late CollectionReference<Map<String, dynamic>> _favoritesCollection;
  late List<dynamic> _favoriteRecipeIds = [];
  late List<dynamic> _recipes = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoadingIds = true;
  bool _isLoadingRecipes = true;

  @override
  void initState() {
    super.initState();
    _favoritesCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('favorites');
    _fetchFavoriteRecipeIds();
  }

  Future<void> _fetchFavoriteRecipeIds() async {
    final snapshot = await _favoritesCollection.get();
    setState(() {
      _favoriteRecipeIds = snapshot.docs.map((doc) => doc.id).toList();
      _isLoadingIds = false;
    });
    print(_favoriteRecipeIds);
    _fetchFavoriteRecipes();
  }

  Future<void> _fetchFavoriteRecipes() async {
    final List<String> ids = _favoriteRecipeIds
        .where((id) => id != 'placeholder')
        .map((id) => id.toString())
        .toList();

    if (ids.isEmpty) {
      setState(() {
        _recipes = [];
        _isLoadingRecipes = false;
      });
      return;
    }

    final String apiUrl =
        '${ApiConfig.baseUrl}/api/recipes/information/?ids=${ids}';
    print(apiUrl);
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _recipes =
            data.map((recipeData) => parseRecipeData(recipeData)).toList();
        print(_recipes);
        _isLoadingRecipes = false;
      });
    } else {
      print('Failed to fetch favorite recipes: ${response.reasonPhrase}');
    }
  }

  Map<String, dynamic> parseRecipeData(Map<String, dynamic> recipeData) {
    // Implement your recipe data parsing logic here
    return recipeData;
  }

  Future<void> _toggleFavorite(String recipeId) async {
    if (_favoriteRecipeIds.contains(recipeId)) {
      _favoriteRecipeIds.remove(recipeId);
      _fetchFavoriteRecipes();
      await _favoritesCollection.doc(recipeId).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Recipes'),
      ),
      body: SingleChildScrollView(
        child: _isLoadingIds
            ? _buildLoadingShimmer()
            : _isLoadingRecipes
                ? _buildLoadingShimmer()
                : _recipes.isEmpty
                    ? Center(
                        child: Text('Nothing is in the favorites'),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _recipes.length,
                        itemBuilder: (context, index) {
                          final recipe = _recipes[index];
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
                                            image: NetworkImage(
                                                recipe['image'] ?? ''),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    RecipeDetailsPage(
                                                        recipeId: recipe['id']),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.favorite),
                                        onPressed: () async {
                                          await _toggleFavorite(
                                              recipe['id'].toString());
                                        },
                                        color: Colors.red,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.access_time),
                                            SizedBox(width: 4),
                                            Text(
                                              '${recipe['readyInMinutes'] ?? ''} min',
                                              style: TextStyle(
                                                fontSize: 14.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            recipe['title'] ?? '',
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildRecipeCardShimmer();
      },
    );
  }

  Widget _buildRecipeCardShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
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
                color: Colors.white,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 100,
                      height: 16,
                      color: Colors.white,
                    ),
                    Expanded(
                      child: Container(
                        height: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
