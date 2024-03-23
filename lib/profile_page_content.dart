import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        // Accessing the documents inside the snapshot
        var documents = snapshot.data!.docs;
        if (documents.isEmpty) {
          return Center(child: Text('No user data found'));
        }

        // Assuming only one document is expected
        var userData = documents.first.data() as Map<String, dynamic>;
        var name = userData['name'];
        var email = userData['email'];

        return Container(
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 100), // Top margin
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Profile Page',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
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
                    // Action for favorites button
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
                  onPressed: () {
                    // Action for logout
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 255, 77, 64),
                    textStyle: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
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
