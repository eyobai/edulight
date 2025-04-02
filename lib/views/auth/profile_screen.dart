import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edulight/models/api_service.dart';
import 'package:edulight/models/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchStudentData(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildProfileSkeletonLoading();
          } else if (snapshot.hasError) {
            return _buildErrorContent(snapshot.error.toString());
          } else if (!snapshot.hasData || snapshot.data == null) {
            return _buildErrorContent('No data available.');
          }

          final studentData = snapshot.data!;
          return _buildProfileContent(studentData);
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> _fetchStudentData(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.user?.userId;
      if (userId == null) {
        throw Exception('User ID not available. Please log in again.');
      }

      // Print the user ID
      print('User ID is: $userId');

      final apiService = Provider.of<ApiService>(context, listen: false);
      return await apiService.fetchStudentData(userId.toString());
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  Widget _buildProfileContent(Map<String, dynamic> studentData) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading:
                Icon(Icons.account_circle, size: 50, color: Colors.blueAccent),
            title: Text(
              studentData['name'] ?? 'Unknown',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(studentData['email'] ?? 'No email available'),
          ),
          SizedBox(height: 16),
          _buildProfileDetail(Icons.phone, 'Phone', studentData['phone']),
          _buildProfileDetail(
              Icons.school, 'School', studentData['school'] ?? 'N/A'),
          _buildProfileDetail(
              Icons.location_city, 'City', studentData['city'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildProfileSkeletonLoading() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _skeletonBox(height: 50, width: 50, shape: BoxShape.circle),
          SizedBox(height: 16),
          _skeletonBox(height: 20, width: 150),
          SizedBox(height: 8),
          _skeletonBox(height: 20, width: 200),
          SizedBox(height: 16),
          _skeletonBox(height: 20, width: 100),
          SizedBox(height: 8),
          _skeletonBox(height: 20, width: 100),
          SizedBox(height: 8),
          _skeletonBox(height: 20, width: 100),
        ],
      ),
    );
  }

  Widget _skeletonBox(
      {double height = 20,
      double width = double.infinity,
      BoxShape shape = BoxShape.rectangle}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: shape,
        borderRadius:
            shape == BoxShape.rectangle ? BorderRadius.circular(8.0) : null,
      ),
    );
  }

  Widget _buildProfileDetail(IconData icon, String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          SizedBox(width: 10),
          Text('$title: ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(
            child: Text(value ?? 'Not available',
                style: TextStyle(fontSize: 16, color: Colors.black54)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 50),
            SizedBox(height: 10),
            Text(
              message,
              style: TextStyle(fontSize: 18, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
