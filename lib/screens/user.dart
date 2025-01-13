import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'profile_page.dart';

class UsersPage extends StatefulWidget {
  final User user;
  final String role;
  final String firstName;
  final String lastName;
  final String phoneNumber;

  const UsersPage({
    super.key,
    required this.user,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
  });

  static Route<dynamic> routeWithArgs(RouteSettings settings) {
    final arguments = settings.arguments as Map<String, dynamic>;
    final User user = arguments['user'];
    final String role = arguments['role'] ?? 'Unknown Role';
    final String firstName = arguments['firstName'] ?? 'First Name';
    final String lastName = arguments['lastName'] ?? 'Last Name';
    final String phoneNumber = arguments['phoneNumber'] ?? 'Phone Number';

    return MaterialPageRoute(
      builder: (context) => UsersPage(
        user: user,
        role: role,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      ),
    );
  }

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  String searchQuery = '';
  String? selectedRole;

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent to $email')),
      );
    } catch (e) {
      print("Error sending password reset email: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Unable to send reset email')),
      );
    }
  }

  void _showAddUserDialog() {
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneNumberController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF9F5EF),
          title: const Text('Add New User'),
          content: SingleChildScrollView(
            child: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: firstNameController,
                    decoration: const InputDecoration(
                      hintText: 'First Name',
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: lastNameController,
                    decoration: const InputDecoration(
                      hintText: 'Last Name',
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: phoneNumberController,
                    decoration: const InputDecoration(
                      hintText: 'Phone Number',
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: 'Admin',
                        child: Text('Admin'),
                      ),
                      DropdownMenuItem(
                        value: 'Sales Staff',
                        child: Text('Sales Staff'),
                      ),
                      DropdownMenuItem(
                        value: 'Inventory Manager',
                        child: Text('Inventory Manager'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Role',
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF6D4C41),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                if (selectedRole != null &&
                    firstNameController.text.isNotEmpty &&
                    lastNameController.text.isNotEmpty &&
                    emailController.text.isNotEmpty &&
                    phoneNumberController.text.isNotEmpty) {
                  usersCollection.add({
                    'firstName': firstNameController.text,
                    'lastName': lastNameController.text,
                    'email': emailController.text,
                    'phoneNumber': phoneNumberController.text,
                    'role': selectedRole,
                  }).then((value) {
                    sendPasswordResetEmail(emailController.text);
                    Navigator.of(context).pop();
                  }).catchError((error) {
                    print("Error adding user: $error");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error adding user')),
                    );
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF6D4C41),
              ),
              child: const Text(
                'Add',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4E342E),
        title:
            const Text('User Management', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    user: widget.user,
                    firstName: widget.firstName,
                    lastName: widget.lastName,
                    phoneNumber: widget.phoneNumber,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by Name',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  DateFormat('MM/dd/yyyy').format(DateTime.now()),
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      usersCollection.orderBy('lastName').limit(20).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error fetching users'));
                    }
                    final users = snapshot.data?.docs ?? [];
                    final filteredUsers = users.where((doc) {
                      final fullName =
                          '${doc['firstName']} ${doc['lastName']}'.toLowerCase();
                      return fullName.contains(searchQuery.toLowerCase());
                    }).toList();

                    return DataTable(
                      headingRowColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 179, 174, 168)),
                      columns: const [
                        DataColumn(label: Text('Actions')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Phone')),
                        DataColumn(label: Text('Role')),
                      ],
                      rows: filteredUsers.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return DataRow(
                          cells: [
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        backgroundColor:
                                            const Color(0xFFF9F5EF),
                                        title: const Text(
                                          'Delete User',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        content: const Text(
                                          'Are you sure you want to delete this user?',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context)
                                                .pop(false),
                                            style: TextButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF6D4C41),
                                            ),
                                            child: const Text(
                                              'Cancel',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            style: TextButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF6D4C41),
                                            ),
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await doc.reference.delete();
                                    }
                                  },
                                ),
                              ],
                            )),
                            DataCell(
                                Text('${data['firstName']} ${data['lastName']}')),
                            DataCell(Text(data['email'] ?? 'N/A')),
                            DataCell(Text(data['phoneNumber'] ?? 'N/A')),
                            DataCell(Text(data['role'] ?? 'N/A')),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        backgroundColor: const Color(0xFF6D4C41),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF9F5EF),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF6D4C41),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 50, color: Color(0xFF6D4C41)),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.firstName + ' ' + widget.lastName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.role,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
              icon: Icons.dashboard,
              text: 'Dashboard',
              onTap: () {
                Navigator.pushNamed(context, '/dashboard');
              }),
          _buildDrawerItem(
              icon: Icons.inventory,
              text: 'Products',
              onTap: () {
                Navigator.pushNamed(context, '/products');
              }),
          _buildDrawerItem(
              icon: Icons.sell,
              text: 'Sales',
              onTap: () {
                Navigator.pushNamed(context, '/sales_transaction');
              }),
          _buildDrawerItem(
              icon: Icons.report,
              text: 'Reports',
              onTap: () {
                Navigator.pushNamed(context, '/sales_report');
              }),
          _buildDrawerItem(
              icon: Icons.people,
              text: 'User Management',
              onTap: () {
                Navigator.pushNamed(context, '/user');
              }),
        ],
      ),
    );
  }
}

Widget _buildDrawerItem({
  required IconData icon,
  required String text,
  required VoidCallback onTap,
}) {
  return ListTile(
    leading: Icon(icon, color: const Color(0xFF4E342E)),
    title: Text(text),
    onTap: onTap,
  );
}