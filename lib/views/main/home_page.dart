import 'package:flutter/material.dart';
import '../../controllers/grade_controller.dart';
import '../../models/grade_model.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedGrade = 8; // Default to Grade 8
  final GradeController _gradeController = GradeController();
  GradeData? _gradeData;

  void _onGradeSelected(int grade) async {
    setState(() {
      _selectedGrade = grade;
    });
    // Fetch data for the selected grade
    _gradeData = await _gradeController.fetchGradeData(grade);
    setState(() {}); // Update the UI with the new data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: Colors.blue.shade50,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),

            // Horizontal List of Grades
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(5, (index) {
                  int grade = 8 + index;
                  return _gradeButton(grade);
                }),
              ),
            ),
            SizedBox(height: 20),

            // Display data based on the selected grade
            Expanded(
              child: _buildGradeContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradeButton(int grade) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () => _onGradeSelected(grade),
        child: Text('Grade $grade'),
      ),
    );
  }

  Widget _buildGradeContent() {
    if (_gradeData == null) {
      return Center(child: CircularProgressIndicator());
    }
    // Display the data for the selected grade as scrollable cards
    return ListView.builder(
      itemCount: _gradeData!.subjects.length,
      itemBuilder: (context, index) {
        final subject = _gradeData!.subjects[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                ...subject.chapters.map((chapter) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chapter.name,
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          chapter.quiz.name,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}
