import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login2.dart';
import 'favorites.dart';

class ProfilePageContent extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('profile')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No user data found'));
        }

        var profileData =
            snapshot.data!.docs.first.data() as Map<String, dynamic>;
        var name = profileData?['username'] ?? 'Username not found';
        var email = profileData?['email'] ?? 'Email not found';

        // Get the first letter of the username
        String firstLetter = name.substring(0, 1).toUpperCase();

        return Container(
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 100),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Profile Page',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    child: Text(
                      firstLetter,
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                  // Add any overlay or decoration you want here
                ],
              ),
              SizedBox(height: 20),
              Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                email,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Action for changing password
                },
                style: TextButton.styleFrom(
                  primary: Colors.white,
                ),
                child: Text(
                  'Change Password',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FavoritePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  icon: Icon(Icons.favorite, color: Colors.red),
                  label: Text(
                    'Favorites',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: () async {
                    // Logout action
                    await _auth.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 255, 77, 64),
                    textStyle:
                        TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                  ),
                  child: Text('Logout'),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
