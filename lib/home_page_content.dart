import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'recipe_details_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'api_config.dart';

class HomePageContent extends StatefulWidget {
  final Map<String, dynamic> userPreferences;

  const HomePageContent({Key? key, required this.userPreferences})
      : super(key: key);

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late CollectionReference<Map<String, dynamic>> _favoritesCollection;

  List<dynamic> _recipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _favoritesCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('favorites');
    _favoritesCollection.doc('placeholder').get().then((snapshot) {
      if (!snapshot.exists) {
        _favoritesCollection.doc('placeholder').set({'placeholder': 'data'});
      }
    });
    fetchData(widget.userPreferences);
  }

  Future<bool> isFavorite(String recipeId) async {
    var querySnapshot = await _favoritesCollection
        .where('recipeId', isEqualTo: recipeId)
        .limit(1)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> fetchData(Map<String, dynamic> preferences) async {
    String baseUrl = '${ApiConfig.baseUrl}/api/recipes/search';
    List<String> queryParams = [];

    preferences.forEach((key, value) {
      if (value != null) {
        if (value is List) {
          String formattedValue =
              value.map((v) => Uri.encodeQueryComponent(v)).join(',');
          queryParams.add('$key=$formattedValue');
        } else {
          queryParams.add('$key=${Uri.encodeQueryComponent(value.toString())}');
        }
      }
    });
    queryParams.add('addRecipeInformation=true');

    String apiUrl = '$baseUrl?${queryParams.join('&')}';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> result = jsonResponse['results'];
      setState(() {
        _recipes = result;
        isLoading = false;
      });
    } else {
      print('Error: ${response.statusCode}');
      isLoading = false;
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

  Future<void> _toggleFavorite(String recipeId) async {
    bool isFav = await isFavorite(recipeId);
    setState(() {
      _recipes.forEach((recipe) {
        if (recipe['id'].toString() == recipeId) {
          recipe['isFavorite'] = !isFav;
        }
      });
    });

    if (isFav) {
      await _favoritesCollection.doc(recipeId).delete();
    } else {
      await _favoritesCollection.doc(recipeId).set({'recipeId': recipeId});
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? _buildLoadingShimmer()
        : ListView.builder(
            itemCount: _recipes.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> recipe = _recipes[index];
              return FutureBuilder<bool>(
                future: isFavorite(recipe['id'].toString()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildRecipeCardShimmer();
                  }
                  bool favorite = snapshot.data ?? false;
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
                                    image: NetworkImage(recipe['image'] ?? ''),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    navigateToRecipeDetails(recipe['id']);
                                  },
                                ),
                              ),
                              IconButton(
                                icon: Icon(favorite
                                    ? Icons.favorite
                                    : Icons.favorite_border),
                                onPressed: () async {
                                  await _toggleFavorite(
                                      recipe['id'].toString());
                                },
                                color: favorite ? Colors.red : null,
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
              );
            },
          );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      itemCount: 5, // Show 5 shimmer cards while loading
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
