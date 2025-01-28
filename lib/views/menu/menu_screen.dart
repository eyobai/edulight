import 'package:flutter/material.dart';
import 'package:edulight/views/auth/login_screen.dart';
import 'package:edulight/views/auth/profile_screen.dart';
import 'package:edulight/views/grades/grade_list_screen.dart';
//import 'package:edulight/views/quizzes/quetions_screen.dart';
import 'package:edulight/views/subscription/subscription_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MenuScreen extends StatelessWidget {
  void _logout(BuildContext context) {
    var box = Hive.box('userBox');
    box.put('isLoggedIn', false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        DrawerHeader(
          // decoration: BoxDecoration(
          //   color: Colors.blueAccent,
          // ),
          child: Text(
            'Menu',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.person),
          title: Text('Profile'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.school),
          title: Text('Grades'),
          onTap: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => GradeListScreen()),
            // );
          },
        ),
        ListTile(
          leading: Icon(Icons.quiz),
          title: Text('Quizzes'),
          // onTap: () {
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(builder: (context) => QuizScreen()),
          //   );
          // },
        ),
        ListTile(
          leading: Icon(Icons.subscriptions),
          title: Text('Subscriptions'),
          onTap: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => SubscriptionScreen()),
            // );
          },
        ),
        ListTile(
          leading: Icon(Icons.logout),
          title: Text('Logout'),
          onTap: () => _logout(context),
        ),
      ],
    );
  }
}
