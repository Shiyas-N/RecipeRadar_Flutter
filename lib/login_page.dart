import 'package:flutter/material.dart';
import 'signup_page.dart';
import 'home_page.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Login / Sign Up'),
      // ),
      body: Stack(
        children: [
          // Background image
          Image.asset(
            'assets/LoginBG.png', // Replace with the actual image path
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Content overlay
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Email input field
                Container(
                  padding: EdgeInsets.all(20.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      labelText: 'Email',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
                // Password input field
                Container(
                  padding: EdgeInsets.all(20.0),
                  child: TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      labelText: 'Password',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Login button
                Container(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      // Implement login functionality
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF5DB075), // #5DB075
                    ),
                    child: Text('Login'),
                  ),
                ),
                // Sign Up text button
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => (SignupPage())),
                    );
                  },
                  style: TextButton.styleFrom(
                    primary: Color(0xFF5DB075), // #5DB075
                  ),
                  child: Text("Don't have an account? Sign up"),
                ),
                // Continue as Guest text button
                TextButton(
                  onPressed: () {
                    // Navigate to home page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              HomePage()), // Replace with the actual route to your home page
                    );
                  },
                  style: TextButton.styleFrom(
                    primary: Color(0xFF5DB075),
                  ),
                  child: Text("Continue as Guest"),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 40.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}