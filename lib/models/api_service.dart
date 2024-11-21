import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String _baseUrl = 'http://10.0.2.2:8000/api';

  Future<http.Response> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    print('Attempting to login with email: $email');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      print('Login response: ${response.body}');
      return response;
    } catch (e) {
      print('Error during login request: $e');
      rethrow;
    }
  }

  Future<http.Response> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    final url = Uri.parse('$_baseUrl/register');
    print('Attempting to register with email: $email');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'phone': phone,
          'password_confirmation': passwordConfirmation,
        }),
      );
      print('Register response: ${response.body}');
      return response;
    } catch (e) {
      print('Error during registration request: $e');
      rethrow;
    }
  }
}
