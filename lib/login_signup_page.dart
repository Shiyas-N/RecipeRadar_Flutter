import 'package:flutter/material.dart';

class LoginSignupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login / Sign Up'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your login and signup forms here
            // For example:
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter your email',
                labelText: 'Email',
              ),
            ),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                labelText: 'Password',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement login functionality
              },
              child: Text('Login'),
            ),
            TextButton(
              onPressed: () {
                // Implement navigation to signup page
              },
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
