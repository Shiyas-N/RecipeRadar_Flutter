import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login / Sign Up'),
      ),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Email input field
                Container(
                  padding: EdgeInsets.all(16.0),
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
                  padding: EdgeInsets.all(16.0),
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
                    // Implement navigation to signup page
                  },
                  style: TextButton.styleFrom(
                    primary: Color(0xFF5DB075), // #5DB075
                  ),
                  child: Text("Don't have an account? Sign up"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
