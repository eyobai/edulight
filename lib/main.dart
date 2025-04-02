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

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Check login state
    var box = Hive.box('userBox');
    bool isLoggedIn = box.get('isLoggedIn', defaultValue: false);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EduLight',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: isLoggedIn ? '/home' : '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/subscription': (context) => SubscriptionScreen(),
      },
    );
  }
}
