import 'package:flutter/material.dart';
import '../../models/api_service.dart';
import '../../controllers/grade_controller.dart';
import '../../models/grade_model.dart';
import '../chapters/chapters_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedGrade = 1; // Default to Grade 8
  final GradeController _gradeController = GradeController();
  final ApiService _apiService = ApiService(); // Instantiate ApiService
  GradeData? _gradeData;
  List<dynamic> _grades = []; // List to store fetched grades
  bool _isLoading = true; // Add a loading state
  List<dynamic> _filteredSubjects = []; // Store filtered subjects

  // List of image paths corresponding to each subject
  final List<String> _subjectImages = [
    'assets/maths.jpg',
    'assets/history.jpg',
    'assets/maths.jpg',
    // Add more image paths as needed
  ];

  @override
  void initState() {
    super.initState();
    _fetchGrades(); // Fetch grades from the API on initialization
  }

  Future<void> _fetchGrades() async {
    try {
      final grades =
          await _apiService.fetchGrades(); // Use ApiService to fetch grades
      setState(() {
        _grades = grades; // Store the grades data
        _isLoading = false; // Set loading to false after fetching
      });
    } catch (e) {
      print('Error fetching grades: $e');
      setState(() {
        _isLoading = false; // Ensure loading is false even on error
      });
    }
  }

  void _onGradeSelected(int gradeId) async {
    setState(() {
      _selectedGrade = gradeId;
    });

    // Fetch data for the selected grade
    _gradeData = await _gradeController.fetchGradeData(gradeId);

    // Fetch subjects for the selected grade
    final subjects = await _apiService.fetchSubjects();
    _filteredSubjects =
        subjects.where((subject) => subject['grade_id'] == gradeId).toList();

    setState(() {}); // Update the UI with the new data
  }

  void refreshSubjects() async {
    if (_selectedGrade != null) {
      _onGradeSelected(_selectedGrade);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(10), // Set a custom height for the AppBar
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false, // Remove the back button
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show skeleton loading while fetching grades
            if (_isLoading)
              _buildSkeletonLoading()
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _grades.map((grade) {
                    return _gradeButton(grade['id'], grade['name']);
                  }).toList(),
                ),
              ),
            SizedBox(height: 20),

            // Display data based on the selected grade
            Expanded(
              child: _isLoading
                  ? _buildSubjectSkeletonLoading()
                  : _buildGradeContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    return Row(
      children: List.generate(3, (index) => _skeletonBox()),
    );
  }

  Widget _skeletonBox() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        width: 100,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _gradeButton(int gradeId, String gradeName) {
    bool isSelected =
        _selectedGrade == gradeId; // Check if the grade is selected
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? Colors.blueGrey
              : Colors.blueAccent, // Different background for selected grade
          foregroundColor: isSelected
              ? Colors.white
              : Colors.white, // Different text color for selected grade
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () {
          print('Selected Grade ID: $gradeId'); // Print the grade ID
          _onGradeSelected(gradeId);
        },
        child: Text(gradeName),
      ),
    );
  }

  Widget _buildSubjectSkeletonLoading() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Two items per row
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: 4, // Number of skeleton items to display
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradeContent() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_filteredSubjects.isEmpty) {
      return Center(child: Text('No subjects available for this grade.'));
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Two items per row
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: _filteredSubjects.length,
      itemBuilder: (context, index) {
        final subject = _filteredSubjects[index];
        final imagePath = _subjectImages[index % _subjectImages.length];

        return GestureDetector(
          onTap: () {
            print(
                'Selected Subject ID: ${subject['id']}'); // Print the subject ID
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChaptersPage(
                  subjectName: subject['name'],
                  subjectId: subject['id'],
                ),
              ),
            );
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Stack(
              children: [
                // Background image
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    imagePath,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Gradient overlay for better text readability
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.black.withOpacity(0.2),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                // Subject name overlay
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      subject['name'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 5.0,
                            color: Colors.black54,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
