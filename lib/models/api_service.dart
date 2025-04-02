import 'dart:convert';
import 'package:edulight/views/quetions/quetions_screen.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart'; // Import Hive for local storage

class ApiService {
  final String _baseUrl = 'http://backend.yeneschool.com/api';
  //final String _baseUrl = 'https://etech.gotechhealth.com/api';
  //final String _baseUrl = 'http://192.168.1.10:8000/api';
  String? _token; // Token is now nullable and will be set after login

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    print('Attempting to login with email: $email');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': email, 'password': password}),
      );
      print('Login response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        var box = Hive.box('userBox');

        // Print debug information
        print('Saving user data:');
        print('Name: ${data['user']['name']}');
        print('Email: ${data['user']['email']}');
        print('ID: ${data['user']['id']}');

        // Save all necessary user data
        box.put('token', _token);
        box.put('isLoggedIn', true);
        box.put('userId', data['user']['id'].toString());
        box.put('userName', data['user']['name']);
        box.put('userEmail', data['user']['email']);

        return data;
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else if (response.statusCode == 401) {
        throw Exception('Invalid credentials');
      } else {
        print('Login failed: ${response.statusCode}');
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during login request: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> register({
    required String name,
    required String lastName,
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
          'name': name,
          'last_name': lastName,
          'email': email,
          'phone': phone,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'userType': 'student'
        }),
      );
      print('Register response: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data.containsKey('token')) {
          _token = data['token'];
          var box = Hive.box('userBox');
          box.put('token', _token);
          box.put('isLoggedIn', true);
          print('Registration successful: Token stored');
          return data;
        } else {
          print('Registration failed: Token not found in response');
          throw Exception('Token not found in response');
        }
      } else if (response.statusCode == 422) {
        // Handle validation errors more gracefully
        final errorMessage = data.entries.map((e) => "${e.value}").join(", ");
        throw Exception(errorMessage);
      } else {
        print('Registration failed with status code: ${response.statusCode}');
        throw Exception('Registration failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during registration request: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> fetchGrades() async {
    final url = Uri.parse('$_baseUrl/grades');
    print('Fetching grades from API');
    try {
      var box = Hive.box('userBox');
      _token = box.get('token'); // Retrieve token from Hive
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token', // Use the stored token
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Grades fetched successfully');
        return data['data'];
      } else {
        print('Failed to fetch grades: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching grades: $e');
      return [];
    }
  }

  Future<List<dynamic>> fetchSubjects() async {
    final url = Uri.parse('$_baseUrl/subjects');
    print('Fetching subjects from API');
    try {
      var box = Hive.box('userBox');
      _token = box.get('token'); // Retrieve token from Hive
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token', // Use the stored token
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Subjects fetched successfully');
        return data['data'];
      } else {
        print('Failed to fetch subjects: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching subjects: $e');
      return [];
    }
  }

  Future<List<dynamic>> fetchChapters(int subjectId) async {
    final url = Uri.parse('$_baseUrl/chapters');
    print('Fetching chapters for subject ID: $subjectId');

    try {
      var box = Hive.box('userBox');
      _token = box.get('token'); // Retrieve token from Hive

      if (_token == null) {
        print('Error: Token is null');
        return [];
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token', // Use the stored token
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract chapters directly from the response
        final chapters = data['data'] as List;

        // Filter chapters by `subjects_id` matching `subjectId`
        return chapters
            .where((chapter) => chapter['subjects_id'] == subjectId)
            .toList();
      } else {
        print('Failed to fetch chapters: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching chapters: $e');
    }

    return [];
  }

  Future<List<dynamic>> fetchQuizzes(int chapterId) async {
    final url = Uri.parse('$_baseUrl/quizzes');
    print('Fetching quizzes for chapter ID: $chapterId');

    try {
      var box = Hive.box('userBox');
      _token = box.get('token'); // Retrieve token from Hive

      if (_token == null) {
        print('Error: Token is null');
        return [];
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token', // Use the stored token
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final quizzes = data['data'] as List;

        // Filter quizzes by `chapters_id` matching `chapterId`
        return quizzes
            .where((quiz) => quiz['chapters_id'] == chapterId)
            .toList();
      } else {
        print('Failed to fetch quizzes: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching quizzes: $e');
    }

    return [];
  }

  Future<List<Question>> fetchQuestions(int quizId) async {
    final url = Uri.parse('$_baseUrl/questions');
    print('Fetching questions for quiz ID: $quizId');

    try {
      var box = Hive.box('userBox');
      _token = box.get('token'); // Retrieve token from Hive

      if (_token == null) {
        print('Error: Token is null');
        return [];
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token', // Use the stored token
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Log the entire response for debugging
        print('Response data: $data');

        // Assuming the response contains a list of questions directly
        if (data['data'] is List) {
          final questions = data['data'] as List;

          // Filter questions by `quiz_id` matching `quizId`
          return questions
              .where((question) => question['quiz_id'] == quizId)
              .map((question) => Question.fromJson(question))
              .toList();
        } else {
          print('Unexpected data format: ${data['data']}');
        }
      } else {
        print('Failed to fetch questions: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching questions: $e');
    }

    return [];
  }

  Future<Map<String, dynamic>?> subscribeToPlan(
      String subscriptionId, String studentId) async {
    final url = Uri.parse('https://backend.yeneschool.com/api/pay');
    print(
        'Attempting to subscribe with subscription ID: $subscriptionId and student ID: $studentId');

    try {
      var box = Hive.box('userBox');
      _token = box.get('token'); // Retrieve token from Hive

      if (_token == null) {
        print('Error: Token is null');
        return null; // Indicate failure
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token', // Use the stored token
        },
        body: jsonEncode({
          'subscription_id': subscriptionId,
          'student_id': studentId,
        }),
      );

      if (response.statusCode == 200) {
        print('Subscription successful');
        return jsonDecode(response.body); // Return the response data
      } else {
        print('Subscription failed: ${response.body}');
        return null; // Indicate failure
      }
    } catch (e) {
      print('Error during subscription request: $e');
      return null; // Indicate failure
    }
  }

  Future<Map<String, dynamic>?> fetchStudentData(String userId) async {
    final url = Uri.parse('$_baseUrl/students/$userId');
    print('Fetching student data for user ID: $userId');

    try {
      var box = Hive.box('userBox');
      _token = box.get('token'); // Retrieve token from Hive

      if (_token == null) {
        print('Error: Token is null');
        return null; // Indicate failure
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token', // Use the stored token
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Student data fetched successfully');
        return data['data']; // Return the student data
      } else {
        print('Failed to fetch student data: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null; // Indicate failure
      }
    } catch (e) {
      print('Error fetching student data: $e');
      return null; // Indicate failure
    }
  }
}
