import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard.dart';

class RoleSelectionPage extends StatefulWidget {
  final User user;

  const RoleSelectionPage({super.key, required this.user});

  @override
  _RoleSelectionPageState createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  String? _selectedRole;
  bool isLoading = true;
  String firstName = '';
  String lastName = '';
  String phoneNumber = '';

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          firstName = doc['firstName'];
          lastName = doc['lastName'];
          phoneNumber = doc['phoneNumber'];
          isLoading = false;
        });
      } else {
        throw Exception('User data not found');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user details: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5EF),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogo(),
            const SizedBox(height: 24),
            _buildTitle(),
            const SizedBox(height: 16),
            _buildRoleButton('Admin'),
            const SizedBox(height: 16),
            _buildRoleButton('Sales Staff'),
            const SizedBox(height: 16),
            _buildRoleButton('Inventory Manager'),
            const SizedBox(height: 24),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      height: 150,
      width: 150,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: AssetImage('assets/logo.png'), // Replace with your logo path
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Role Selection',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Please select your role in Dahliy Kek Lapis Premium.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRoleButton(String role) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedRole = role;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedRole == role
              ? Colors.grey[600]// Dark grey for selected role
              : Colors.grey[300], // Light grey for unselected role
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          elevation: 0,
        ),
        child: Text(
          role,
          style: TextStyle(
            fontSize: 16,
            color: _selectedRole == role ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _selectedRole == null
          ? null
          : () async {
              try {
                // Update the role in Firestore
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.user.uid)
                    .update({'role': _selectedRole});
                debugPrint('Role updated successfully to $_selectedRole');    

                // Fetch the updated user document to ensure role is set
                DocumentSnapshot updatedDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.user.uid)
                    .get();
                final updatedRole = updatedDoc['role'];
                final updatedFirstName = updatedDoc['firstName'];
                final updatedLastName = updatedDoc['lastName'];
                final updatedPhoneNumber = updatedDoc['phoneNumber'];

                // Navigate to the DashboardPage with updated role
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DashboardPage(
                      user: widget.user,
                      role: updatedRole,
                      firstName: updatedFirstName,
                      lastName: updatedLastName,
                      phoneNumber: updatedPhoneNumber,
                    ),
                  ),
                );
              } catch (e) {
                debugPrint('Error updating role: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update role: $e')),
                );
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4E342E), // Dark brown confirm button
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        elevation: 0,
      ),
      child: const Text(
        'Confirm',
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    ),
  );
}

}
