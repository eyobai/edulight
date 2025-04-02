import 'package:edulight/views/quizzes/webview_screen.dart';
import 'package:flutter/material.dart';
import 'package:edulight/models/api_service.dart';
import 'package:edulight/views/quetions/quetions_screen.dart'; // Import the QuetionScreen
import 'package:edulight/views/subscription/subscription_screen.dart'; // Import the SubscriptionScreen
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:edulight/models/user_provider.dart';

class QuizScreen extends StatelessWidget {
  final int chapterId;
  final ApiService _apiService = ApiService();

  QuizScreen({required this.chapterId});

  @override
  Widget build(BuildContext context) {
    // Access the user ID from the UserProvider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.userId;

    // Print the user ID
    print('User ID: $userId');

    return Scaffold(
      appBar: AppBar(
        title: Text('Quizzes'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _apiService.fetchQuizzes(chapterId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildQuizSkeletonLoading();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching quizzes'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No quizzes available'));
          } else {
            final quizzes = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                  childAspectRatio: 4 / 3,
                ),
                itemCount: quizzes.length,
                itemBuilder: (context, index) {
                  final quiz = quizzes[index];
                  final color = Colors
                      .primaries[index % Colors.primaries.length]
                      .withOpacity(0.7);

                  return GestureDetector(
                    onTap: () async {
                      // Access the user ID from the UserProvider
                      final userProvider =
                          Provider.of<UserProvider>(context, listen: false);
                      final userId = userProvider.user?.userId;

                      if (userId == null) {
                        // Handle the case where the user ID is not available
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'User ID not available. Please log in again.')),
                        );
                        return;
                      }

                      // Fetch the student's data from the API
                      final studentData =
                          await _apiService.fetchStudentData(userId);

                      if (studentData == null) {
                        // Handle the case where student data could not be fetched
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed to fetch student data.')),
                        );
                        return;
                      }

                      // Check if the selected quiz ID is in the student's quizzes
                      final studentQuizzes =
                          studentData['quizes'] as List<dynamic>;
                      final isQuizAlreadyTaken =
                          studentQuizzes.any((studentQuiz) {
                        return studentQuiz['quiz_id'] == quiz['id'];
                      });

                      if (isQuizAlreadyTaken) {
                        // Navigate to QuetionScreen if the quiz is already taken
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                QuetionScreen(quizId: quiz['id']),
                          ),
                        );
                      } else if (quiz['is_demo'] == 1) {
                        final subscription = quiz['subscription'];
                        if (subscription != null && subscription.isNotEmpty) {
                          // Print the subscription ID
                          final subscriptionId = subscription[0]['id'];
                          print('Subscription ID: $subscriptionId');

                          // Show a dialog with the subscription details
                          final subscriptionDetails = subscription[0];
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Subscription Details'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Name: ${subscriptionDetails['name']}'),
                                    SizedBox(height: 8),
                                    Text(
                                        'Description: ${subscriptionDetails['description']}'),
                                    SizedBox(height: 8),
                                    Text(
                                        'Price: \$${subscriptionDetails['price']}'),
                                    SizedBox(height: 8),
                                    Text(
                                        'Expiry Date: ${subscriptionDetails['expiry_date']}'),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Close'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      // Access the user ID from the UserProvider
                                      final userProvider =
                                          Provider.of<UserProvider>(context,
                                              listen: false);
                                      final studentId =
                                          userProvider.user?.userId;

                                      if (studentId == null) {
                                        // Handle the case where the user ID is not available
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'User ID not available. Please log in again.')),
                                        );
                                        return;
                                      }

                                      // Extract the subscription ID from the quiz data
                                      final subscription = quiz['subscription'];
                                      if (subscription != null &&
                                          subscription.isNotEmpty) {
                                        final subscriptionId = subscription[0]
                                                ['id']
                                            .toString(); // Use the first subscription ID
                                        print(
                                            'Subscription ID: $subscriptionId');

                                        try {
                                          // Call the subscribeToPlan method
                                          final response =
                                              await _apiService.subscribeToPlan(
                                                  subscriptionId, studentId);

                                          if (response != null) {
                                            // Load the callback URL in InAppWebView
                                            final callbackUrl =
                                                response['callback_url'];
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    WebViewScreen(
                                                        url: callbackUrl),
                                              ),
                                            );
                                          } else {
                                            // Handle error
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Subscription failed. No response received.')),
                                            );
                                          }
                                        } catch (e) {
                                          // Log the error and show a message
                                          print(
                                              'Error during subscription: $e');
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'An error occurred during subscription.')),
                                          );
                                        }
                                      } else {
                                        // Handle the case where no subscription is available
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'No subscription available for this quiz.')),
                                        );
                                      }
                                    },
                                    child: Text('Subscribe Now'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          // Navigate to QuetionScreen if no subscription is available
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  QuetionScreen(quizId: quiz['id']),
                            ),
                          );
                        }
                      } else {
                        // Fetch questions for the selected quiz
                        final questions =
                            await _apiService.fetchQuestions(quiz['id']);

                        // Print each question and its options
                        for (var question in questions) {
                          print('Question: ${question.questionText}');
                          for (var option in question.options) {
                            print(
                                'Option: ${option.optionText} - Correct: ${option.isCorrect}');
                          }
                        }

                        // Navigate to QuetionScreen with the selected quiz ID
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                QuetionScreen(quizId: quiz['id']),
                          ),
                        );
                      }
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                      shadowColor: Colors.indigoAccent.withOpacity(0.9),
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            quiz['name'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildQuizSkeletonLoading() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          childAspectRatio: 4 / 3,
        ),
        itemCount: 4, // Number of skeleton items to display
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 4,
            shadowColor: Colors.indigoAccent.withOpacity(0.9),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          );
        },
      ),
    );
  }
}
