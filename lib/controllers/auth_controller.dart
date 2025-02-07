import 'dart:convert';
import 'package:edulight/models/api_service.dart';
import 'package:edulight/models/student_model.dart'; // Import your student model
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http; // Add this import

class AuthController {
  final ApiService _apiService = ApiService();

  Future<StudentModel?> login(String email, String password) async {
    try {
      final data = await _apiService.login(email, password);
      if (data != null && data.containsKey('user')) {
        return StudentModel.fromJson(data);
      } else {
        throw Exception('User data not found in response');
      }
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _apiService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      var box = Hive.box('userBox');
      String? token = box.get('token');

      if (token != null) {
        // Registration was successful
        print('Registration successful');
        return true;
      } else {
        // Handle registration failure
        print('Registration failed: Token not found');
        return false;
      }
    } catch (e) {
      print('Error during registration: $e');
      return false;
    }
  }

  Future<StudentModel?> loginWithPhone(String phone, String password) async {
    try {
      final data = await _apiService.login(phone, password);
      if (data != null && data.containsKey('user')) {
        return StudentModel.fromJson(data);
      } else {
        throw Exception('User data not found in response');
      }
    } catch (e) {
      print('Error during login with phone: $e');
      return null;
    }
  }
}
