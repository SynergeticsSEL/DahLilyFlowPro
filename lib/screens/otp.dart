import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart'; // Import your login page
import 'dashboard.dart';
import 'role_selection.dart'; // Import your role selection page

class OTPPage extends StatefulWidget {
  final User user;

  const OTPPage({
    super.key,
    required this.user,
  });

  @override
  _OTPPageState createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  @override
  void initState() {
    super.initState();
    _sendVerificationEmail();
  }

  Future<void> _sendVerificationEmail() async {
    try {
      await widget.user.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification link sent to your email')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send verification email')),
      );
    }
  }

  Future<void> _checkEmailVerified() async {
    try {
      // Retry checking for verification status a few times
      int retries = 5;
      bool isVerified = false;
      User? updatedUser;

      while (retries > 0 && !isVerified) {
        await widget.user.reload();
        updatedUser = FirebaseAuth.instance.currentUser;

        if (updatedUser?.emailVerified ?? false) {
          isVerified = true;
        } else {
          retries--;
          await Future.delayed(Duration(seconds: 3));  // Wait for 3 seconds before retrying
        }
      }

      if (isVerified) {
        // Fetch user data from Firestore to check if the role is already set
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(updatedUser?.uid).get();

        if (userDoc.exists) {
          final role = userDoc['role'];
          print("User role: $role");

          if (role != null && role.isNotEmpty) {
            // If role is found and not empty, navigate to the DashboardPage
            final firstName = userDoc['firstName'];
            final lastName = userDoc['lastName'];
            final phoneNumber = userDoc['phoneNumber'];

            print("Navigating to DashboardPage...");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardPage(
                  user: updatedUser!,
                  role: role,
                  firstName: firstName,
                  lastName: lastName,
                  phoneNumber: phoneNumber,
                ),
              ),
            );
          } else {
            // If no role is set or role is empty, navigate to RoleSelectionPage
            print("No role found, navigating to RoleSelectionPage...");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => RoleSelectionPage(user: updatedUser!),
              ),
            );
          }
        } else {
          // If user document doesn't exist, navigate to login page directly
          print("User document doesn't exist, navigating to LoginPage...");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginPage(
                email: '',  // Default email
                password: '',  // Default password
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email is not yet verified')),
        );
      }
    } catch (e) {
      print("Error during email verification check: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to verify email')),
      );
      // If error occurs, navigate to login page as fallback
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(
            email: '',  // Default email
            password: '',  // Default password
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5EF),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildLogo(),
              const SizedBox(height: 24),
              const Text(
                'Verify Your Email',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'A verification link has been sent to your email. Please click the link to verify your account.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity, // Make the button stretch horizontally
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E342E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _checkEmailVerified,
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _sendVerificationEmail,
                child: const Text(
                  'Resend Email',
                  style: TextStyle(
                    color: Color(0xFF4E342E),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
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
          image: AssetImage('assets/logo.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
