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
    required String lastName,
  }) async {
    try {
      final data = await _apiService.register(
        name: name,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      if (data != null) {
        // Extract the 'id' from the 'student' object
        if (data.containsKey('student') && data['student'].containsKey('id')) {
          String studentId =
              data['student']['id'].toString(); // Fetch the actual student ID

          var box = Hive.box('userBox');
          box.put('userId', studentId); // Store the student ID in Hive

          print('Registration successful: Student ID stored');
          return true;
        } else {
          print('Registration failed: Student ID not found');
          return false;
        }
      } else {
        print('Registration failed: No data returned');
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
