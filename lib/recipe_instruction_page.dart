import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';

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
          '${ApiConfig.baseUrl}/api/recipe-instruction/${widget.recipeId}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data != null && data.isNotEmpty && data[0]['steps'] != null) {
        setState(() {
          instructions = data[0]['steps'];
        });
      } else {
        // Handle the case where the data or steps are null or empty
        print('Instructions data is null or empty');
      }
    } else {
      print('Failed to fetch instructions');
    }
  }

  void goToNextStep() {
    setState(() {
      if (currentIndex < instructions!.length - 1) {
        currentIndex++;
      }
    });
  }

  void goToPreviousStep() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Instructions'),
      ),
      body: instructions == null
          ? Center(child: CircularProgressIndicator())
          : buildCarousel(),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: currentIndex > 0 ? goToPreviousStep : null,
            ),
            Text('${currentIndex + 1}/${instructions!.length}'),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed:
                  currentIndex < instructions!.length - 1 ? goToNextStep : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCarousel() {
    return PageView.builder(
      itemCount: instructions!.length,
      controller: PageController(initialPage: currentIndex),
      onPageChanged: (index) {
        setState(() {
          currentIndex = index;
        });
      },
      itemBuilder: (context, index) {
        return buildStepPage(instructions![index]);
      },
    );
  }

  Widget buildStepPage(dynamic instruction) {
    if (instruction['steps'] != null && instruction['steps'].isNotEmpty) {
      final step = instruction['steps'][0];
      if (step != null) {
        return Card(
          margin: EdgeInsets.all(8),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step ${step['number']}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  step['step'],
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        );
      }
    }
    // Return an empty container if there are no steps or if the step is null
    return Container();
  }
}
