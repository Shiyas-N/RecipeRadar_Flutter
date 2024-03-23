import 'package:flutter/material.dart';
import 'refrigerator_page_content.dart';
import 'home_page.dart';

class RecipeInstructionPage extends StatelessWidget {
  final List<dynamic> analyzedInstructions;

  const RecipeInstructionPage({Key? key, required this.analyzedInstructions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: analyzedInstructions.length,
        itemBuilder: (context, index) {
          final instruction = analyzedInstructions[index];
          List<dynamic> steps = instruction['steps'];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 75.0),
                  child: Text(
                    'Instructions',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...steps.map((step) {
                  List<dynamic>? ingredients = step['ingredients'];
                  List<dynamic>? equipment = step['equipment'];
                  String instructionText = step['step'];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          instructionText,
                          style: TextStyle(fontSize: 20),
                        ),
                        if (ingredients != null && ingredients.isNotEmpty)
                          ...ingredients.map((ingredient) {
                            return Card(
                              child: ListTile(
                                leading:
                                    _buildIngredientImage(ingredient['image']),
                                title: Text(ingredient['name']),
                              ),
                            );
                          }).toList(),
                        // Display equipment with images and names
                        if (equipment != null && equipment.isNotEmpty)
                          ...equipment.map((equipmentItem) {
                            return Card(
                              child: ListTile(
                                leading: _buildEquipmentImage(
                                    equipmentItem['image']),
                                title: Text(equipmentItem['name']),
                              ),
                            );
                          }).toList(),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(top: 16.0, left: 16.0),
        child: ClipOval(
          child: Material(
            color: const Color.fromARGB(255, 0, 0, 0),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: SizedBox(
                width: 48,
                height: 48,
                child: Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
      persistentFooterButtons: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Remember to update ingredient quantities in your Inventory!'),
                  ),
                );
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (route) => false,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RefrigeratorPageContent(),
                  ),
                );
              },
              child: Text('Finish', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientImage(String? imageName) {
    if (imageName == null || imageName.isEmpty) {
      // Placeholder image
      return SizedBox(
        width: 100,
        height: 100,
        child: Icon(Icons.image),
      );
    }

    // Use Image.network for loading the ingredient image
    return Image.network(
      'https://spoonacular.com/cdn/ingredients_100x100/$imageName',
      width: 100,
      height: 100,
      fit: BoxFit.cover,
    );
  }

  Widget _buildEquipmentImage(String? imageName) {
    if (imageName == null || imageName.isEmpty) {
      // Placeholder image
      return SizedBox(
        width: 100,
        height: 100,
        child: Icon(Icons.image),
      );
    }

    // Use Image.network for loading the equipment image
    return Image.network(
      'https://spoonacular.com/cdn/equipment_100x100/$imageName',
      width: 50,
      height: 50,
      fit: BoxFit.cover,
    );
  }
}
