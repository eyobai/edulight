class GradeModel {
  Future<GradeData> getGradeData(int grade) async {
    // Default values
    String description = 'General Grade Information';
    List<Subject> subjects = [];

    switch (grade) {
      case 8:
        description = 'Introduction to Algebra and Geometry';
        subjects = [
          Subject(
            name: 'Algebra',
            chapters: [
              Chapter(name: 'Chapter 1', quiz: Quiz(name: 'Quiz 1')),
              Chapter(name: 'Chapter 2', quiz: Quiz(name: 'Quiz 2')),
            ],
          ),
          Subject(
            name: 'Geometry',
            chapters: [
              Chapter(name: 'Chapter 1', quiz: Quiz(name: 'Quiz 1')),
            ],
          ),
        ];
        break;
      // Add cases for other grades similarly
      default:
        // Ensure subjects is initialized to an empty list if no case matches
        subjects = [];
        break;
    }

    return GradeData(
      grade: grade,
      data: 'Sample data for grade $grade',
      description: description,
      subjects: subjects,
    );
  }
}

class GradeData {
  final int grade;
  final String data;
  final String description;
  final List<Subject> subjects;

  GradeData({
    required this.grade,
    required this.data,
    required this.description,
    required this.subjects,
  });
}

class Subject {
  final String name;
  final List<Chapter> chapters;

  Subject({
    required this.name,
    required this.chapters,
  });
}

class Chapter {
  final String name;
  final Quiz quiz;

  Chapter({
    required this.name,
    required this.quiz,
  });
}

class Quiz {
  final String name;

  Quiz({
    required this.name,
  });
}
