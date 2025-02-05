import 'package:edulight/views/auth/login_screen.dart';
import 'package:edulight/views/menu/menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:edulight/views/auth/profile_screen.dart'; // Import the ProfileScreen
import 'package:edulight/views/main/home_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:edulight/models/user_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<HomePageState> _homePageKey = GlobalKey<HomePageState>();
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

  void _logout() {
    var box = Hive.box('userBox');
    box.put('isLoggedIn', false);
    setState(() {
      _isLoggedIn = false;
    });
    // Navigate to the login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  List<Widget> _getWidgetOptions() {
    return <Widget>[
      HomePage(key: _homePageKey),
      ProfileScreen(),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        // children: [
        //   Text('Menu'),
        //   ElevatedButton(
        //     onPressed: () {
        //       _logout();
        //     },
        //     child: Text('Logout'),
        //   ),
        // ],
      ),
    ];
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      // Open the drawer when the "Menu" tab is selected
      _scaffoldKey.currentState?.openDrawer();
    } else {
      setState(() {
        _selectedIndex = index;
      });
      if (index == 0) {
        // Refresh subjects when Home tab is selected
        _homePageKey.currentState?.refreshSubjects();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      // Redirect to login screen if not logged in
      return LoginScreen();
    }

    final user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      key: _scaffoldKey,
      appBar: _selectedIndex == 0 // Check if Home tab is selected
          ? PreferredSize(
              preferredSize:
                  Size.fromHeight(100), // Set the height of the AppBar
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(
                      80), // Set the radius for the bottom right corner
                ),
                child: AppBar(
                  automaticallyImplyLeading: false, // Remove the back button
                  backgroundColor: Colors.blueAccent,
                  elevation: 0,
                  flexibleSpace: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 36, horizontal: 20),
                    child: Align(
                      alignment:
                          Alignment.bottomLeft, // Align text to the bottom left
                      child: Text(
                        'Hello, ${user?.name ?? 'Guest'} 👋 ',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Text color for contrast
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null, // No AppBar for other tabs
      drawer: Drawer(
        child: MenuScreen(), // Use your MenuScreen here
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            // Use Expanded to fill the remaining space
            child: _getWidgetOptions().elementAt(_selectedIndex),
          ),
        ],
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
        selectedItemColor: Colors.blue[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
