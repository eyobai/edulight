import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edulight/models/api_service.dart';
import 'package:edulight/models/user_provider.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Details',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchSubscribedQuizzes(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error.toString());
          } else if (!snapshot.hasData || snapshot.data == null) {
            return _buildNoDataWidget();
          }

          final quizzes = snapshot.data!['quizes'] as List<dynamic>;
          return _buildQuizList(quizzes);
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> _fetchSubscribedQuizzes(
      BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.userId;

    if (userId == null) {
      throw Exception('User ID not available. Please log in again.');
    }

    final apiService = Provider.of<ApiService>(context, listen: false);
    return await apiService.fetchStudentData(userId);
  }

  Widget _buildQuizList(List<dynamic> quizzes) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subscribed Quizzes:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: quizzes.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final quiz = quizzes[index]['quiz'];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12.0),
                    title: Text(
                      quiz['name'],
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('Quiz ID: ${quizzes[index]['quiz_id']}'),
                    // leading: const Icon(Icons.quiz, color: Colors.blueAccent),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.redAccent, size: 50),
            const SizedBox(height: 12),
            Text(
              'Error: $errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: Colors.grey, size: 50),
            SizedBox(height: 12),
            Text(
              'No data available.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
