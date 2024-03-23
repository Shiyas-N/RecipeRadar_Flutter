import 'package:flutter/material.dart';
import 'home_page_content.dart';
import 'search_page_content.dart';
import 'refrigerator_page_content.dart';
import 'shopping_cart_page_content.dart';
import 'profile_page_content.dart';
import 'recipe.dart';

class HomePage extends StatefulWidget {
  // const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final double _selectedIconSize = 35.0;
  final double _unselectedIconSize = 30.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPage(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF4CAF50),
        currentIndex: _currentIndex,
        selectedItemColor: Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: _unselectedIconSize,
        items: [
          _buildNavBarItem(Icons.home, 0),
          _buildNavBarItem(Icons.search, 1),
          _buildNavBarItem(Icons.kitchen, 2),
          _buildNavBarItem(Icons.shopping_cart, 3),
          _buildNavBarItem(Icons.person, 4),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavBarItem(IconData icon, int index) {
    return BottomNavigationBarItem(
      icon: index == _currentIndex ? _selectedIcon(icon) : Icon(icon),
      label: '',
    );
  }

  Widget _selectedIcon(IconData icon) {
    return Transform.scale(
      scale: _selectedIconSize / _unselectedIconSize,
      child: Icon(icon, size: _selectedIconSize),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return HomePageContent();
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
