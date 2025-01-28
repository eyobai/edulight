import 'dart:math';
import 'package:flutter/material.dart';
import 'package:edulight/models/api_service.dart';

class QuetionScreen extends StatefulWidget {
  final int quizId;

  QuetionScreen({required this.quizId});

  @override
  _QuetionScreenState createState() => _QuetionScreenState();
}

class _QuetionScreenState extends State<QuetionScreen> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = true;
  int _correctAnswersCount = 0;
  int _incorrectAnswersCount = 0;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  void _fetchQuestions() async {
    final questions = await _apiService.fetchQuestions(widget.quizId);
    setState(() {
      _questions = questions;
      _isLoading = false;
    });

    // Print the questions for debugging
    for (var question in _questions) {
      print('Question: ${question.questionText}');
    }
  }

  void _nextQuestion(bool isCorrect) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final correctOption =
        currentQuestion.options.firstWhere((option) => option.isCorrect);

    setState(() {
      if (isCorrect) {
        _correctAnswersCount++;
      } else {
        _incorrectAnswersCount++;
      }

      // Show dialog with explanation
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(isCorrect ? 'Correct Answer' : 'Incorrect Answer'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isCorrect)
                  Text('Correct Answer: ${correctOption.optionText}'),
                SizedBox(height: 8),
                Text('Explanation: ${currentQuestion.explanation}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (_currentQuestionIndex < _questions.length - 1) {
                    _currentQuestionIndex++;
                  } else {
                    _showCompletionDialog();
                  }
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quiz Completed'),
        content: Text(
          'You have answered all the questions!\n'
          'Correct: $_correctAnswersCount\n'
          'Incorrect: $_incorrectAnswersCount',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentQuestionIndex = 0;
                _correctAnswersCount = 0;
                _incorrectAnswersCount = 0;
              });
            },
            child: Text('Restart'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Questions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildQuestionCard(),
    );
  }

  Widget _buildQuestionCard() {
    if (_questions.isEmpty) {
      return Center(child: Text('No questions available'));
    }

    final question = _questions[_currentQuestionIndex];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${_currentQuestionIndex + 1}/${_questions.length}',
            style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600]),
          ),
          SizedBox(height: 10.0),
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                question.questionText,
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          Expanded(
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                final option = question.options[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: InkWell(
                    onTap: () {
                      _nextQuestion(option.isCorrect);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        option.optionText,
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Question {
  final String questionText;
  final List<Option> options;
  final String explanation;

  Question({
    required this.questionText,
    required this.options,
    required this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionText: json['question_text'],
      options: (json['options'] as List?)
              ?.map((option) => Option.fromJson(option))
              .toList() ??
          [],
      explanation: json['explanation'],
    );
  }
}

class Option {
  final String optionText;
  final bool isCorrect;

  Option({
    required this.optionText,
    required this.isCorrect,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      optionText: json['option_text'],
      isCorrect: json['is_correct'] == 1,
    );
  }
}
