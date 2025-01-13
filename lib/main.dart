import 'package:flutter/material.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/otp.dart';
import 'screens/role_selection.dart';
import 'screens/dashboard.dart';
import 'screens/user.dart';
import 'screens/products.dart';
import 'screens/sales_transaction.dart';
import 'screens/sales_report.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const SalesInventoryApp());
}

class SalesInventoryApp extends StatelessWidget {
  const SalesInventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sales & Inventory System',
      theme: ThemeData(fontFamily: 'Poppins'),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(email: '', password: ''),
        '/login': (context) => const LoginPage(email: '', password: ''),
        '/register': (context) => const RegisterPage(),
        '/otp': (context) {
          final user = ModalRoute.of(context)!.settings.arguments as User;
          return OTPPage(user: user);
        },
        '/role_selection': (context) {
          final user = ModalRoute.of(context)!.settings.arguments as User;
          return RoleSelectionPage(user: user);
        },
        '/dashboard': (context) => FutureBuilder<Map<String, String>>(
              future: _fetchUserDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Scaffold(
                    body: Center(
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  );
                } else if (snapshot.hasData) {
                  final user = FirebaseAuth.instance.currentUser!;
                  final userDetails = snapshot.data!;
                  return DashboardPage(
                    user: user,
                    firstName: userDetails['firstName']!,
                    lastName: userDetails['lastName']!,
                    phoneNumber: userDetails['phoneNumber']!,
                    role: userDetails['role']!,
                  );
                } else {
                  return const Scaffold(
                    body: Center(child: Text('Failed to load user details.')),
                  );
                }
              },
            ),
        '/products': (context) => FutureBuilder<Map<String, String>>(
              future: _fetchUserDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Scaffold(
                    body: Center(
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  );
                } else if (snapshot.hasData) {
                  final user = FirebaseAuth.instance.currentUser!;
                  final userDetails = snapshot.data!;
                  return ProductsPage(
                    user: user,
                    firstName: userDetails['firstName']!,
                    lastName: userDetails['lastName']!,
                    phoneNumber: userDetails['phoneNumber']!,
                    role: userDetails['role']!,
                  );
                } else {
                  return const Scaffold(
                    body: Center(child: Text('Failed to load user details.')),
                  );
                }
              },
            ),
        '/sales_transaction': (context) => FutureBuilder<Map<String, String>>(
              future: _fetchUserDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Scaffold(
                    body: Center(
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  );
                } else if (snapshot.hasData) {
                  final user = FirebaseAuth.instance.currentUser!;
                  final userDetails = snapshot.data!;
                  return SalesTransactionPage(
                    user: user,
                    firstName: userDetails['firstName']!,
                    lastName: userDetails['lastName']!,
                    phoneNumber: userDetails['phoneNumber']!,
                    role: userDetails['role']!,
                  );
                } else {
                  return const Scaffold(
                    body: Center(child: Text('Failed to load user details.')),
                  );
                }
              },
            ),
        '/sales_report': (context) => FutureBuilder<Map<String, String>>(
              future: _fetchUserDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Scaffold(
                    body: Center(
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  );
                } else if (snapshot.hasData) {
                  final user = FirebaseAuth.instance.currentUser!;
                  final userDetails = snapshot.data!;
                  return SalesReportPage(
                    user: user,
                    firstName: userDetails['firstName']!,
                    lastName: userDetails['lastName']!,
                    phoneNumber: userDetails['phoneNumber']!,
                    role: userDetails['role']!,
                  );
                } else {
                  return const Scaffold(
                    body: Center(child: Text('Failed to load user details.')),
                  );
                }
              },
            ),
            '/user': (context) => FutureBuilder<Map<String, String>>(
              future: _fetchUserDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Scaffold(
                    body: Center(
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  );
                } else if (snapshot.hasData) {
                  final user = FirebaseAuth.instance.currentUser!;
                  final userDetails = snapshot.data!;
                  return UsersPage(
                    user: user,
                    firstName: userDetails['firstName']!,
                    lastName: userDetails['lastName']!,
                    phoneNumber: userDetails['phoneNumber']!,
                    role: userDetails['role']!,
                  );
                } else {
                  return const Scaffold(
                    body: Center(child: Text('Failed to load user details.')),
                  );
                }
              },
            ), 
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          return FutureBuilder<Map<String, String>>(
            future: _fetchUserDetails(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return Scaffold(
                  body: Center(
                    child: Text('Error: ${snapshot.error}'),
                  ),
                );
              } else if (snapshot.hasData) {
                final userDetails = snapshot.data!;
                final role = userDetails['role']!;
                // Navigate to the appropriate page based on the user's role
                if (role == 'Admin') {
                  return DashboardPage(
                    user: user,
                    firstName: userDetails['firstName']!,
                    lastName: userDetails['lastName']!,
                    phoneNumber: userDetails['phoneNumber']!,
                    role: role,
                  );
                } else {
                  return RoleSelectionPage(user: user);
                }
              } else {
                return const Scaffold(
                  body: Center(
                    child: Text('Failed to load user details.'),
                  ),
                );
              }
            },
          );
        } else {
          return const LoginPage(email: '', password: '');
        }
      },
    );
  }
}

Future<Map<String, String>> _fetchUserDetails() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    throw Exception('No user is logged in');
  }

  try {
    // Assuming you have a Firestore collection named 'users'
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid) // Use the user's UID as the document ID
        .get();

    if (!docSnapshot.exists) {
      throw Exception('User document does not exist in Firestore');
    }

    final data = docSnapshot.data()!;
    return {
      'firstName': data['firstName'] as String? ?? 'Unknown',
      'lastName': data['lastName'] as String? ?? 'Unknown',
      'phoneNumber': data['phoneNumber'] as String? ?? 'Unknown',
      'role': data['role'] as String? ?? 'Unknown',
    };
  } catch (e) {
    throw Exception('Failed to fetch user details: $e');
  }
}
