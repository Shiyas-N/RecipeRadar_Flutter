import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'signup_page.dart';
import 'home_page.dart';
import 'recipe.dart';

class LoginPage extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final List<Recipe> recipeData; // Add recipeData as a parameter

  LoginPage(
      {required this.recipeData}); // Add constructor to receive recipeData

  Future<void> signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // User signed in successfully, you can navigate to the next screen or perform other actions.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(recipeData: recipeData)),
      );
    } catch (e) {
      // Handle sign-in errors
      print(e.toString());

      // Display a snackbar with the error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign-in failed: ${e.toString()}'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> signUpWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // User signed up successfully
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(recipeData: recipeData)),
      );
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign-up failed: ${e.toString()}'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.normal,
                          fontSize: 16.0,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'Enter your email',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                // Password input field
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.normal,
                          fontSize: 16.0,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5.0),
                SizedBox(height: 20),
                // Login button
                ElevatedButton(
                  onPressed: () async {
                    // Call the signInWithEmailAndPassword method
                    await signInWithEmailAndPassword(context,
                        _emailController.text, _passwordController.text);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomePage(
                                recipeData: recipeData,
                              )),
                    );
                  },
                  child: Text('Sign In',
                      style: GoogleFonts.inter(color: Color(0xFF5DB075))),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(15),
                    backgroundColor: const Color.fromARGB(255, 1, 101, 252),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    minimumSize: const Size(380, 0),
                  ),
                ),
                const SizedBox(height: 35),

                // Container(
                //   width: 200,
                //   child: ElevatedButton(
                //     onPressed: () {
                //       // Implement login functionality
                //     },
                //     style: ElevatedButton.styleFrom(
                //       primary: Color(0xFF5DB075), // #5DB075
                //     ),
                //     child: Text('Login'),
                //   ),
                // ),
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
                          builder: (context) => HomePage(
                                recipeData: recipeData,
                              )), // Replace with the actual route to your home page
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
