import 'package:flutter/material.dart';
import 'package:edulight/controllers/auth_controller.dart';
import 'package:edulight/views/main/home_screen.dart';
import 'package:edulight/views/auth/register_screen.dart';
import 'package:provider/provider.dart';
import 'package:edulight/models/user.dart';
import 'package:edulight/models/user_provider.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatelessWidget {
  final AuthController _authController = AuthController();
  final TextEditingController _phoneController =
      TextEditingController(text: '+251');
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return Container(
              margin: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _header(context),
                  _inputField(context),
                  _forgotPassword(context),
                  _signup(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  _header(context) {
    return const Column(
      children: [
        Text(
          "Welcome",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text("Enter your credential to login"),
      ],
    );
  }

  _inputField(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _phoneController,
          decoration: InputDecoration(
            hintText: "Phone Number",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none),
            fillColor: Colors.blue.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          style: const TextStyle(fontSize: 16),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\+251\d*')),
          ],
          onChanged: (value) {
            if (!value.startsWith('+251')) {
              _phoneController.text = '+251';
              _phoneController.selection = TextSelection.fromPosition(
                TextPosition(offset: _phoneController.text.length),
              );
            }
          },
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            hintText: "Password",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none),
            fillColor: Colors.blue.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.password),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            String phoneNumber = _phoneController.text.trim();
            print('Attempting to login with phone number: $phoneNumber');
            var student = await _authController.loginWithPhone(
              phoneNumber,
              _passwordController.text,
            );
            if (student != null) {
              Provider.of<UserProvider>(context, listen: false).setUser(
                User(
                  email: student.email,
                  name: student.name,
                  userId: student.id.toString(),
                ),
              );

              var box = Hive.box('userBox');
              box.put('isLoggedIn', true);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Login successful')),
              );

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Login failed')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.blue,
          ),
          child: const Text(
            "Login",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        )
      ],
    );
  }

  _forgotPassword(context) {
    return TextButton(
      onPressed: () {},
      child: const Text(
        "Forgot password?",
        style: TextStyle(color: Colors.blue),
      ),
    );
  }

  _signup(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? "),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegisterScreen()),
            );
          },
          child: const Text("Sign Up", style: TextStyle(color: Colors.blue)),
        )
      ],
    );
  }
}
