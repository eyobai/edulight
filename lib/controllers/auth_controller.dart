import 'dart:convert';
import 'package:edulight/models/api_service.dart';
import 'package:edulight/models/student_model.dart'; // Import your student model

class AuthController {
  final ApiService _apiService = ApiService();

  Future<StudentModel?> login(String email, String password) async {
    try {
      // Call the API service to perform login
      final response = await _apiService.login(email, password);
      if (response.statusCode == 200) {
        // Parse the response and return a StudentModel
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print('JSON Response: ${response.body}');
        return StudentModel.fromJson(responseData);
      } else {
        // Handle login failure
        throw Exception('Login failed: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Handle any exceptions
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
      final response = await _apiService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      if (response.statusCode == 201) {
        // Registration was successful
        print('Registration successful');
        return true;
      } else {
        // Handle other status codes or errors
        print('Registration failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during registration: $e');
      return false;
    }
  }
}
