import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edulight/views/auth/login_screen.dart';
import 'package:edulight/views/auth/register_screen.dart';
import 'package:edulight/views/main/home_screen.dart';
import 'package:edulight/models/user_provider.dart';
//import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // // Initialize Hive
  // await Hive.initFlutter();
  // await Hive.openBox('userBox');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Check login state
    // var box = Hive.box('userBox');
    // bool isLoggedIn = box.get('isLoggedIn', defaultValue: false);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Your App',
      //  initialRoute: isLoggedIn ? '/home' : '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
