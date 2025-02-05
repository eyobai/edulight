class StudentModel {
  final int id;
  final String name;
  final String email;
  final String token;

  StudentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
  });

  // Factory method to create a StudentModel from JSON
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    // Extract the first student entry
    final studentData = json['user']['student'][0];
    return StudentModel(
      id: studentData['id'], // Use the id from the student array
      name: json['user']['name'],
      email: json['user']['email'],
      token: json['token'],
    );
  }

  // Method to convert a StudentModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
    };
  }
}
