import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_page.dart';

class DashboardPage extends StatelessWidget {
  final User user;
  final String role;
  final String firstName;
  final String lastName;
  final String phoneNumber;

  const DashboardPage({
    super.key,
    required this.user,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
  });

  // Named route support for passing arguments
  static Route<dynamic> routeWithArgs(RouteSettings settings) {
    final arguments = settings.arguments as Map<String, dynamic>;
    final User user = arguments['user'];
    final String role = arguments['role'] ?? 'Unknown Role';
    final String firstName = arguments['firstName'] ?? 'First Name';
    final String lastName = arguments['lastName'] ?? 'Last Name';
    final String phoneNumber = arguments['phoneNumber'] ?? 'Phone Number';

    return MaterialPageRoute(
      builder: (context) => DashboardPage(
        user: user,
        role: role,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5EF),
      appBar: AppBar(
        title: Text(
          'Dashboard - $role',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4E342E),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    user: user,
                    firstName: firstName,
                    lastName: lastName,
                    phoneNumber: phoneNumber,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  OverviewCard(
                    title: 'Revenue',
                    amount: '+30,000',
                    color: Colors.green[300],
                  ),
                  OverviewCard(
                    title: 'Sales Return',
                    amount: '+30,000',
                    color: Colors.red[300],
                  ),
                  OverviewCard(
                    title: 'Purchase',
                    amount: '+30,000',
                    color: Colors.orange[300],
                  ),
                  OverviewCard(
                    title: 'Income',
                    amount: '+30,000',
                    color: Colors.blue[300],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (role == 'Admin') ...[
              _buildNavigationCard(
                  context, 'Products', Icons.inventory, '/products'),
              _buildNavigationCard(
                  context, 'Sales Transactions', Icons.sell, '/sales_transaction'),
              _buildNavigationCard(
                  context, 'Sales Reports', Icons.bar_chart, '/sales_report'),
              _buildNavigationCard(
                  context, 'Users', Icons.people, '/user'),
            ] else if (role == 'Sales Staff') ...[
              _buildNavigationCard(
                  context, 'Sales Transactions', Icons.sell, '/sales_transaction'),
              _buildNavigationCard(
                  context, 'Sales Reports', Icons.bar_chart, '/sales_report'),
            ] else if (role == 'Inventory Manager') ...[
              _buildNavigationCard(
                  context, 'Products', Icons.inventory, '/products'),
            ] else ...[
              Center(
                child: Text(
                  'Unknown Role',
                  style: const TextStyle(fontSize: 18, color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF9F5EF),
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF4E342E)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 80,
                  width: 80,
                ),
                const Spacer(),
                const Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Menu',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ],
            ),
          ),
          if (role == 'Admin') ...[
            _buildDrawerItem(icon: Icons.dashboard, text: 'Dashboard', onTap: () {
              Navigator.pop(context); //Close the drawer
            }),
            _buildDrawerItem(icon: Icons.inventory, text: 'Products', onTap: () {
              Navigator.pushNamed(context, '/products');
            }),
            _buildDrawerItem(icon: Icons.sell, text: 'Sales', onTap: () {
              Navigator.pushNamed(context, '/sales_transaction');
            }),
            _buildDrawerItem(icon: Icons.report, text: 'Reports', onTap: () {
              Navigator.pushNamed(context, '/sales_report');
            }),
            _buildDrawerItem(icon: Icons.people, text: 'User Management', onTap: () {
              Navigator.pushNamed(context, '/user');
            }),
          ] else if (role == 'Sales Staff') ...[
            _buildDrawerItem(icon: Icons.dashboard, text: 'Dashboard', onTap: () {
              Navigator.pop(context);
            }),
            _buildDrawerItem(icon: Icons.sell, text: 'Sales', onTap: () {
              Navigator.pushNamed(context, '/sales_transaction');
            }),
            _buildDrawerItem(icon: Icons.report, text: 'Reports', onTap: () {
              Navigator.pushNamed(context, '/sales_report');
            }),
          ] else if (role == 'Inventory Manager') ...[
            _buildDrawerItem(icon: Icons.dashboard, text: 'Dashboard', onTap: () {
              Navigator.pop(context);
            }),
            _buildDrawerItem(icon: Icons.inventory, text: 'Products', onTap: () {
              Navigator.pushNamed(context, '/products');
            }),
          ],
        ],
      ),
    );
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

  Widget _buildNavigationCard(BuildContext context, String label, IconData icon, String route) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFDCC6AE), // Slightly darker beige
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // Shadow position
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.brown, size: 40), // Icon in brown color
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.brown,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

}

class OverviewCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color? color;

  const OverviewCard({
    super.key,
    required this.title,
    required this.amount,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 10),
            Text(amount,
                style: const TextStyle(fontSize: 24, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
