import 'package:edulight/views/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:edulight/views/auth/profile_screen.dart'; // Import the ProfileScreen
import 'package:edulight/views/main/home_page.dart';
import 'package:provider/provider.dart';
import 'package:edulight/models/user_provider.dart';
import 'package:hive/hive.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    var box = Hive.box('userBox');
    setState(() {
      _isLoggedIn = box.get('isLoggedIn', defaultValue: false);
    });
  }

  static List<Widget> _widgetOptions = <Widget>[
    HomePage(), // HomePage defaults to Grade 8
    ProfileScreen(), // Use the new ProfileScreen
    Text('welcome'), // Replace with your Menu widget
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    var box = Hive.box('userBox');
    box.put('isLoggedIn', false);
    setState(() {
      _isLoggedIn = false;
    });
    // Optionally, navigate to the login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      // Redirect to login screen if not logged in
      return LoginScreen();
    }

    final user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edu light'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedIndex == 0) // Check if Home tab is selected
              Text(
                'Hello, ${user?.name ?? 'Guest'} 👋 ',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 20),
            // Display the selected widget
            Expanded(
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
