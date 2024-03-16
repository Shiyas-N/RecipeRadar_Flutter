import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'recipe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RecipeRadar',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  List<Recipe> recipeData = [];

  @override
  void initState() {
    super.initState();
    loadRecipeData();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(recipeData: recipeData),
        ),
      );
    });
  }

  Future<void> loadRecipeData() async {
    try {
      String jsonData = await DefaultAssetBundle.of(context)
          .loadString('assets/allrecipedata.json');

      final Map<String, dynamic> jsonMap = json.decode(jsonData);
      List<dynamic> recipesJson = jsonMap['recipes'];

      
      setState(() {
        recipeData = recipesJson
            .map((recipeJson) => Recipe.fromJson(recipeJson))
            .toList();
      });
    } catch (e) {
      print('Error loading recipe data: $e');
      // Handle the error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'RecipeRadar',
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
