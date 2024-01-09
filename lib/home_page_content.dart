import 'package:flutter/material.dart';

class HomePageContent extends StatelessWidget {
  // Example list of recipes with image URLs and names
  final List<Map<String, dynamic>> recipes = [
    {
      'name': 'Rajgira Chikki',
      'image':
          'https://c.ndtvimg.com/2024-01/u7it9rj_chikki_120x90_05_January_24.jpg', // Replace with actual image URL
    },
    {
      'name': 'Himachali Chicken Curry',
      'image':
          'https://c.ndtvimg.com/2023-12/efrl2jm8_chicken-curry_625x300_24_December_23.jpg', // Replace with actual image URL
    },
    // Add more recipe entries as needed...
  ];

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
                  height: 200, // Adjust the height as needed
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image:
                          NetworkImage(recipes[index]['image']), // Recipe image
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      // Implement navigation to recipe details page
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    recipes[index]['name'], // Recipe name
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
