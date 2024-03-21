import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';


class SignupPage extends StatelessWidget {
  const SignupPage({Key? key});
  

  Future<void> _createAccount(
      BuildContext context, String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Account creation successful, navigate to the home page or display success message
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Account created successfully!'),
      //     duration: Duration(seconds: 3),
      //   ),
      // );
      // You can navigate to another page upon successful sign-up
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(recipeData: [],)),
      );
    } catch (e) {
      // Handle sign-up errors
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create account: ${e.toString()}'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _usernameController = TextEditingController();
    TextEditingController _firstNameController = TextEditingController();
    TextEditingController _lastNameController = TextEditingController();
    TextEditingController _emailController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();

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
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Username input field
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: 'Username',
                        labelText: 'Username',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                  // First name input field
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        hintText: 'First Name',
                        labelText: 'First Name',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                  // Last name input field
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        hintText: 'Last Name',
                        labelText: 'Last Name',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                  // Email input field
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        labelText: 'Email',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                  // Password input field
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextField(
                      controller: _passwordController,
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
                  // Continue button
                  Container(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _createAccount(context, _emailController.text,
                            _passwordController.text);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFF5DB075), // #5DB075
                      ),
                      child: Text('Continue'),
                    ),
                  ),
                  // Login text button
                  TextButton(
                    onPressed: () {
                      // Implement navigation to login page
                    },
                    style: TextButton.styleFrom(
                      primary: Color(0xFF5DB075), // #5DB075
                    ),
                    child: Text("Already have an account? Log in"),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 40.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
