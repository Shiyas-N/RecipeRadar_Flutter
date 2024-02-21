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
    return FutureBuilder<List<Recipe>>(
      future: loadRecipeData(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          List<Recipe> recipeData = snapshot.data!;
          return MaterialApp(
            title: 'RecipeRadar',
            theme: ThemeData(
              primarySwatch: Colors.green,
            ),
            home: SplashScreen(recipeData: recipeData),
            debugShowCheckedModeBanner: false,
          );
        } else {
          // You can return a loading indicator or other UI while waiting
          return CircularProgressIndicator();
        }
      },
    );
  }
}

Future<List<Recipe>> loadRecipeData(BuildContext context) async {
  try {
    String jsonData = await DefaultAssetBundle.of(context)
        .loadString('assets/allrecipedata.json');

    final Map<String, dynamic> jsonMap = json.decode(jsonData);
    List<dynamic> recipesJson = jsonMap['recipes'];

    List<Recipe> recipes =
        recipesJson.map((recipeJson) => Recipe.fromJson(recipeJson)).toList();

    return recipes;
  } catch (e) {
    print('Error loading recipe data: $e');
    return []; // Return an empty list or handle it as needed
  }
}

class SplashScreen extends StatefulWidget {
  final List<Recipe> recipeData;

  SplashScreen({required this.recipeData});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    final recipeData = widget.recipeData;
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(recipeData: recipeData),
        ),
      );
    });
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
