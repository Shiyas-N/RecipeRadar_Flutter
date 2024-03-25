import 'package:flutter/material.dart';
import 'home_page_content.dart';
import 'search_page_content.dart';
import 'refrigerator_page_content.dart';
import 'test.dart';
import 'profile_page_content.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> userPreferences; // User preferences parameter

  HomePage({Key? key, required this.userPreferences}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: _buildPage(_currentIndex),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          type: BottomNavigationBarType.fixed, // Set type to fixed
          currentIndex: _currentIndex,
          selectedItemColor: Color(0xFF4CAF50),
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: [
            _buildNavBarItem(Icons.home, 'Home'),
            _buildNavBarItem(Icons.search, 'Search'),
            _buildNavBarItem(Icons.kitchen, 'Inventory'),
            _buildNavBarItem(Icons.shopping_cart, 'Shopping'),
            _buildNavBarItem(Icons.person, 'Profile'),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavBarItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return HomePageContent(userPreferences: widget.userPreferences);
      case 1:
        return SearchPageContent();
      case 2:
        return RefrigeratorPageContent();
      case 3:
        return ShoppingCartPageContent();
      case 4:
        return ProfilePageContent();
      default:
        return Container();
    }
  }
}
