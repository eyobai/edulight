// grade_controller.dart
import '../models/grade_model.dart';

class GradeController {
  final GradeModel _gradeModel = GradeModel();

  Future<GradeData> fetchGradeData(int grade) async {
    // Logic to fetch data for the specified grade
    return await _gradeModel.getGradeData(grade);
  }
}
