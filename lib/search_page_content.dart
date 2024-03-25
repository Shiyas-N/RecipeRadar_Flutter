import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'recipe_details_page.dart';

import 'api_config.dart';

class SearchPageContent extends StatefulWidget {
  const SearchPageContent({Key? key}) : super(key: key);

  @override
  _SearchPageContentState createState() => _SearchPageContentState();
}

class _SearchPageContentState extends State<SearchPageContent> {
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];

  RangeValues _caloriesRangeValues = RangeValues(100, 1000);
  RangeValues _proteinRangeValues = RangeValues(0, 100);
  RangeValues _fatRangeValues = RangeValues(0, 100);

  List<String> _selectedDishTypes = [];
  List<String> _selectedCuisines = [];
  List<String> _selectedDiets = [];

  List<String> dishTypes = [
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
  ];

  List<String> cuisines = [
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
    'Mediterranean',
  ];

  List<String> diets = [
    'Gluten Free',
    'Ketogenic',
    'Vegetarian',
    'Lacto-Vegetarian',
    'Ovo-Vegetarian',
    'Vegan',
    'Pescetarian',
  ];

  void _fetchSearchResults(String query) async {
    if (query.length < 3) {
      return;
    }

    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/api/recipes/search?query=$query'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> results = jsonResponse['results'];
      setState(() {
        _searchResults = results;
      });
    } else {
      throw Exception('Failed to load search results');
    }
  }

  void _savePreferences() async {
    String query = _searchController.text;
    String cuisineQuery = _selectedCuisines.isNotEmpty
        ? 'cuisine=${_selectedCuisines.join(',')}'
        : '';
    String typeQuery = _selectedDishTypes.isNotEmpty
        ? 'type=${_selectedDishTypes.join(',')}'
        : '';
    String dietQuery =
        _selectedDiets.isNotEmpty ? 'diet=${_selectedDiets.join(',')}' : '';
    String minCaloriesQuery =
        'minCalories=${_caloriesRangeValues.start.round()}';
    String maxCaloriesQuery = 'maxCalories=${_caloriesRangeValues.end.round()}';
    String minProteinQuery = 'minProtein=${_proteinRangeValues.start.round()}';
    String maxProteinQuery = 'maxProtein=${_proteinRangeValues.end.round()}';
    String minFatQuery = 'minFat=${_fatRangeValues.start.round()}';
    String maxFatQuery = 'maxFat=${_fatRangeValues.end.round()}';

    String url =
        '${ApiConfig.baseUrl}/api/recipes/search?query=$query&$cuisineQuery&$typeQuery&$dietQuery&$minCaloriesQuery&$maxCaloriesQuery&$minProteinQuery&$maxProteinQuery&$minFatQuery&$maxFatQuery';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> results = jsonResponse['results'];
        setState(() {
          _searchResults = results;
        });
      } else {
        throw Exception('Failed to load search results');
      }
    } catch (error) {
      print('Error fetching recipes: $error');
    }
  }

  Widget buildFilterSection() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Options',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            buildDropdown(
              title: 'Dish Types',
              selectedValues: _selectedDishTypes,
              items: dishTypes,
              onChanged: (value) {
                setState(() {
                  _selectedDishTypes = value;
                });
              },
            ),
            SizedBox(height: 16),
            buildDropdown(
              title: 'Cuisines',
              selectedValues: _selectedCuisines,
              items: cuisines,
              onChanged: (value) {
                setState(() {
                  _selectedCuisines = value;
                });
              },
            ),
            SizedBox(height: 16),
            buildDropdown(
              title: 'Diets',
              selectedValues: _selectedDiets,
              items: diets,
              onChanged: (value) {
                setState(() {
                  _selectedDiets = value;
                });
              },
            ),
            SizedBox(height: 16),
            Text(
              'Nutritional Values',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            buildRangeSlider(
              title: 'Calories',
              rangeValues: _caloriesRangeValues,
              min: 100,
              max: 1000,
              onChanged: (values) {
                setState(() {
                  _caloriesRangeValues = values;
                });
              },
            ),
            buildRangeSlider(
              title: 'Protein',
              rangeValues: _proteinRangeValues,
              min: 0,
              max: 100,
              onChanged: (values) {
                setState(() {
                  _proteinRangeValues = values;
                });
              },
            ),
            buildRangeSlider(
              title: 'Fat',
              rangeValues: _fatRangeValues,
              min: 0,
              max: 100,
              onChanged: (values) {
                setState(() {
                  _fatRangeValues = values;
                });
              },
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _clearFilters,
                  child: Text('Clear'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _savePreferences,
                  child: Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDropdown({
    required String title,
    required List<String> selectedValues,
    required List<String> items,
    required ValueChanged<List<String>> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Wrap(
          spacing: 8,
          children: items.map((item) {
            bool isSelected = selectedValues.contains(item);
            return FilterChip(
              label: Text(item),
              selected: isSelected,
              onSelected: (bool selected) {
                List<String> newSelectedValues = List.from(selectedValues);
                if (selected) {
                  newSelectedValues.add(item);
                } else {
                  newSelectedValues.remove(item);
                }
                onChanged(newSelectedValues);
              },
              selectedColor: Colors.lightGreenAccent,
            );
          }).toList(),
        ),
      ],
    );
  }

  // void _applyFilters() {
  //   print('Selected Dish Types: $_selectedDishTypes');
  //   print('Selected Cuisines: $_selectedCuisines');
  //   print('Selected Diets: $_selectedDiets');
  //   print('Selected Calories Range: $_caloriesRangeValues');
  //   print('Selected Protein Range: $_proteinRangeValues');
  //   print('Selected Fat Range: $_fatRangeValues');

  //   // Implement your filtering logic here
  // }

  void _clearFilters() {
    setState(() {
      _selectedDishTypes = [];
      _selectedCuisines = [];
      _selectedDiets = [];
      _caloriesRangeValues = RangeValues(100, 1000);
      _proteinRangeValues = RangeValues(0, 100);
      _fatRangeValues = RangeValues(0, 100);
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Search Recipes",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
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
                        controller: _searchController,
                        onChanged: (value) {
                          _fetchSearchResults(value);
                        },
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search here...',
                            prefixIcon: Icon(Icons.search)),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: _showFilterBottomSheet,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade400,
                                blurRadius: 10,
                                spreadRadius: 3,
                                offset: const Offset(5, 5))
                          ]),
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(
                          Icons.sort,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    if (_searchResults.isNotEmpty &&
                        index < _searchResults.length) {
                      final recipe = _searchResults[index];
                      final int recipeId = recipe['id'];
                      final String recipeTitle = recipe['title'];
                      final String recipeImageUrl = recipe['image'];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RecipeDetailsPage(recipeId: recipeId),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 4,
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            leading: recipeImageUrl != null
                                ? Image.network(
                                    recipeImageUrl,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                : SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: Center(child: Text('No Image')),
                                  ),
                            title: Text(recipeTitle),
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return buildFilterSection();
          },
        );
      },
    );
  }

  Widget buildRangeSlider({
    required String title,
    required RangeValues rangeValues,
    required double min,
    required double max,
    required ValueChanged<RangeValues> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        RangeSlider(
          values: rangeValues,
          min: min,
          max: max,
          divisions: ((max - min) / 10).toInt(),
          labels: RangeLabels(
            rangeValues.start.round().toString(),
            rangeValues.end.round().toString(),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
