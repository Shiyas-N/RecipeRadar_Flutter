import 'package:flutter/material.dart';
import 'login_signup_page.dart';
import 'home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RecipeRadar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Change initialRoute based on your authentication logic
      initialRoute: '/home',
      routes: {
        '/': (context) => LoginSignupPage(),
        '/home': (context) => HomePage(),
        // Add more routes for different pages if needed
      },
    );
  }
}
