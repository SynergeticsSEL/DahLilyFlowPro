import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_page.dart'; // Ensure this is imported for the profile page

class SalesReportPage extends StatefulWidget {
  final User user;
  final String role;
  final String firstName;
  final String lastName;
  final String phoneNumber;

  const SalesReportPage({
    super.key,
    required this.user,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
  });

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  DateTime selectedDate = DateTime.now();
  String searchQuery = '';
  List<Map<String, dynamic>> completedSales = [];
  List<bool> checkedValues = []; // To track checkbox states

  @override
  void initState() {
    super.initState();
    fetchCompletedSales();
  }

  Future<void> fetchCompletedSales() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('sales')
        .where('status', isEqualTo: 'Completed')
        .get();

    setState(() {
      completedSales = querySnapshot.docs.map((doc) {
        // Check for null values and provide defaults
        final data = doc.data() as Map<String, dynamic>;
        return {
          'saleID': data['saleID'] ?? 'Unknown', // Default value if null
          'date': data['date'] ?? 'Unknown', // Default value if null
          'customer': data['customer'] ?? 'Unknown', // Default value if null
          'product': data['product'] ?? 'Unknown', // Default value if null
          'items': data['items'] ?? 0, // Default value if null
        };
      }).toList();
      checkedValues = List.generate(completedSales.length, (index) => false); // Initialize checkbox states
    });
  }

  void searchSales(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  void filterByDate(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredSales = completedSales.where((sale) {
      bool matchesSearchQuery = sale['saleID'].toString().contains(searchQuery);
      bool matchesDate = DateFormat('yyyy-MM-dd').format(selectedDate) == sale['date'];
      return matchesSearchQuery && matchesDate;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4E342E),
        title: const Text('Sales Report', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              // Navigate to Profile Page
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sales Report', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search Sale ID',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onChanged: (value) => searchSales(value),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Text(DateFormat('MM/dd/yyyy').format(selectedDate)),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2025, 12, 31), // Updated lastDate
                          );
                          if (picked != null) {
                            filterByDate(picked);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(const Color.fromARGB(255, 179, 174, 168)),
                    columns: const [
                      DataColumn(label: Text('')),
                      DataColumn(label: Text('Sale ID')),
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Customer')),
                      DataColumn(label: Text('Products')),
                      DataColumn(label: Text('Items')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: filteredSales.map((sale) {
                      int index = filteredSales.indexOf(sale);
                      return DataRow(
                        cells: [
                          DataCell(
                            Checkbox(
                              value: checkedValues[index],
                              onChanged: (bool? value) {
                                setState(() {
                                  checkedValues[index] = value ?? false;
                                });
                              },
                            ),
                          ),
                          DataCell(Text(sale['saleID'])),
                          DataCell(Text(sale['date'])),
                          DataCell(Text(sale['customer'])),
                          DataCell(Text(sale['product'])),
                          DataCell(Text(sale['items'].toString())),
                          DataCell(Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text('Completed', style: TextStyle(color: Colors.white)),
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Drawer widget with role-based access
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
                  'assets/logo.png', // Ensure your logo is in the assets folder
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
          if (widget.role == 'Admin') ...[
            _buildDrawerItem(icon: Icons.dashboard, text: 'Dashboard', onTap: () {
              Navigator.pushNamed(context, '/dashboard');
            }),
            _buildDrawerItem(icon: Icons.inventory, text: 'Products', onTap: () {
              Navigator.pushNamed(context, '/products');
            }),
            _buildDrawerItem(icon: Icons.sell, text: 'Sales', onTap: () {
              Navigator.pushNamed(context, '/sales_transaction');
            }),
            _buildDrawerItem(icon: Icons.report, text: 'Reports', onTap: () {
              Navigator.pushNamed(context, '/sales_reports');
            }),
            _buildDrawerItem(icon: Icons.people, text: 'User Management', onTap: () {
              Navigator.pushNamed(context, '/user');
            }),
          ] else if (widget.role == 'Sales Staff') ...[
            _buildDrawerItem(icon: Icons.dashboard, text: 'Dashboard', onTap: () {
              Navigator.pushNamed(context, '/dashboard');
            }),
            _buildDrawerItem(icon: Icons.sell, text: 'Sales', onTap: () {
              Navigator.pushNamed(context, '/sales_transaction');
            }),
            _buildDrawerItem(icon: Icons.report, text: 'Reports', onTap: () {}),
          ] else if (widget.role == 'Inventory Manager') ...[
            _buildDrawerItem(icon: Icons.dashboard, text: 'Dashboard', onTap: () {
              Navigator.pushNamed(context, '/dashboard');
            }),
            _buildDrawerItem(icon: Icons.inventory, text: 'Products', onTap: () {
              Navigator.pushNamed(context, '/products');
            }),
          ],
        ],
      ),
    );
  }

  // Helper method to build drawer items
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
}
