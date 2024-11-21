class StudentModel {
  final int id;
  final String name;
  final String email;

  StudentModel({
    required this.id,
    required this.name,
    required this.email,
  });

  // Factory method to create a StudentModel from JSON
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['user']['id'],
      name: json['user']['name'],
      email: json['user']['email'],
    );
  }

  // Method to convert a StudentModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
