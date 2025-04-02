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

  void _checkLoginStatus() async {
    var box = Hive.box('userBox');
    bool isLoggedIn = box.get('isLoggedIn', defaultValue: false);
    String? token = box.get('token');

    if (!isLoggedIn || token == null) {
      _redirectToLogin();
      return;
    }

    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  void _redirectToLogin() {
    var box = Hive.box('userBox');
    box.put('isLoggedIn', false);
    box.delete('token');

    // Clear user data from provider
    Provider.of<UserProvider>(context, listen: false).clearUser();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _logout() {
    _redirectToLogin();
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
    final user = Provider.of<UserProvider>(context).user;

    // Check if user is not logged in or user data is not available
    if (!_isLoggedIn || user == null) {
      return LoginScreen();
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: _selectedIndex == 0
          ? PreferredSize(
              preferredSize: Size.fromHeight(100),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(80),
                ),
                child: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.blueAccent,
                  elevation: 0,
                  flexibleSpace: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        //  'Hello, ${user.name} 👋 ',
                        'Hello  👋',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
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
