import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RecipeInstructionPage extends StatefulWidget {
  final int recipeId;

  RecipeInstructionPage({Key? key, required this.recipeId}) : super(key: key);

  @override
  _RecipeInstructionPageState createState() => _RecipeInstructionPageState();
}

class _RecipeInstructionPageState extends State<RecipeInstructionPage> {
  List<dynamic>? instructions;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch instructions when the widget is created
    fetchInstructions();
  }

  Future<void> fetchInstructions() async {
    final response = await http.get(
      Uri.parse(
          'http://localhost:8080/api/recipe-instruction/${widget.recipeId}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        instructions = data;
      });
    } else {
      // Handle error
      print('Failed to fetch instructions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Instructions'),
      ),
      body: instructions == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: instructions![currentIndex]['steps'].length,
                    itemBuilder: (context, index) {
                      return buildStepCard(
                          instructions![currentIndex]['steps'][index]);
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Check if there are more steps at the current index
                    if (currentIndex < instructions!.length - 1 &&
                        currentIndex <
                            instructions![currentIndex]['steps'].length - 1) {
                      // Increment the index and rebuild the widget
                      setState(() {
                        currentIndex++;
                        print("now=$currentIndex");
                      });
                    } else {
                      print('No more instructions');
                    }
                  },
                  child: Text('Next'),
                ),
              ],
            ),
    );
  }

  Widget buildStepCard(Map<String, dynamic> stepData) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step ${stepData['number']}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              stepData['step'],
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
