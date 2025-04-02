import 'package:edulight/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edulight/views/auth/login_screen.dart';
import 'package:edulight/views/auth/register_screen.dart';
import 'package:edulight/views/main/home_screen.dart';
import 'package:edulight/models/user_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:edulight/models/api_service.dart';
import 'package:edulight/views/subscription/subscription_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('userBox');

  // Check and restore user data
  var box = Hive.box('userBox');
  final isLoggedIn = box.get('isLoggedIn', defaultValue: false);
  final userProvider = UserProvider();

  if (isLoggedIn) {
    // Restore user data to provider
    userProvider.setUser(
      User(
        email: box.get('userEmail', defaultValue: ''),
        name: box.get('userName', defaultValue: ''),
        userId: box.get('userId', defaultValue: ''),
      ),
    );
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        ChangeNotifierProvider<UserProvider>.value(
          value: userProvider,
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EduLight',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          var box = Hive.box('userBox');
          bool isLoggedIn = box.get('isLoggedIn', defaultValue: false);

          // If logged in and user data exists, go to HomeScreen
          if (isLoggedIn && userProvider.user != null) {
            return HomeScreen();
          }
          // Otherwise, go to LoginScreen
          return LoginScreen();
        },
      ),
    );
  }
}
