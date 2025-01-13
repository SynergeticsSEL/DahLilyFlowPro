import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_page.dart';
import 'add_sale.dart';

class SalesTransactionPage extends StatefulWidget {
  final User user;
  final String role;
  final String firstName;
  final String lastName;
  final String phoneNumber;

  const SalesTransactionPage({
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
      builder: (context) => SalesTransactionPage(
        user: user,
        role: role,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      ),
    );
  }

  @override
  State<SalesTransactionPage> createState() => _SalesTransactionPageState();
}

class _SalesTransactionPageState extends State<SalesTransactionPage> {
  final CollectionReference salesCollection =
      FirebaseFirestore.instance.collection('sales');

  String selectedStatus = 'All';
  List<String> statusOptions = ['All', 'Completed', 'Pending'];
  String searchQuery = '';

  Future<void> _addSale(Map<String, String> newSale) async {
    int itemsCount = int.parse(newSale['items'] ?? '0');
    await salesCollection.add({
      'saleID': newSale['saleID'],
      'date': DateTime.now().toString().split(' ')[0],
      'customer': newSale['customerName'],
      'product': newSale['productName'],
      'items': itemsCount,
      'status': newSale['saleStatus'],
    });
  }

  Future<void> _editSaleStatus(String docId, String currentStatus) async {
    final newStatus = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String selected = currentStatus;
        return AlertDialog(
          backgroundColor: const Color(0xFFF9F5EF),
          title: const Text('Edit Sale Status'),
          content: DropdownButton<String>(
            value: selected,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selected = value;
                });
              }
            },
            items: ['Completed', 'Pending']
                .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    ))
                .toList(),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF4E342E)
              ),
              onPressed: () => Navigator.pop(context, null),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
                ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF4E342E)
              ),
              onPressed: () => Navigator.pop(context, selected),
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (newStatus != null && newStatus != currentStatus) {
      await salesCollection.doc(docId).update({'status': newStatus});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5EF), 
      appBar: AppBar(
        backgroundColor: const Color(0xFF4E342E),
        title: const Text('Sales Transaction', style: TextStyle(color: Colors.white)),
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
      drawer: Drawer(
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
              Navigator.pushNamed(context, '/sales_report');
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
            _buildDrawerItem(icon: Icons.report, text: 'Reports', onTap: () {
              Navigator.pushNamed(context, '/sales_report');
            }),
          ],
        ],
      ),
    ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: selectedStatus,
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value!;
                    });
                  },
                  items: statusOptions
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: salesCollection.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error fetching sales data'));
                  }
                  final sales = snapshot.data?.docs ?? [];
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(
                            const Color.fromARGB(255, 179, 174, 168)),
                        columns: const [
                          DataColumn(label: Text('Sale ID')),
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Customer')),
                          DataColumn(label: Text('Products')),
                          DataColumn(label: Text('Items')),
                          DataColumn(label: Text('Status')),
                        ],
                        rows: sales
                            .map((DocumentSnapshot document) {
                              Map<String, dynamic> sale =
                                  document.data() as Map<String, dynamic>;
                              return DataRow(cells: [
                                DataCell(Text(sale['saleID'] ?? '')),
                                DataCell(Text(sale['date'] ?? '')),
                                DataCell(Text(sale['customer'] ?? '')),
                                DataCell(Text(sale['product'] ?? '')),
                                DataCell(Text(sale['items'].toString())),
                                DataCell(
                                  GestureDetector(
                                    onTap: () {
                                      _editSaleStatus(document.id, sale['status'] ?? '');
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: sale['status'] == 'Completed'
                                            ? Colors.green
                                            : Colors.orange,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        sale['status'] ?? '',
                                        style:
                                            const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ]);
                            })
                            .toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4E342E),
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 32.0),
                minimumSize: const Size(150, 50),
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddSalePage(
                      onAddSale: (newSale) {
                        _addSale(newSale);
                      },
                    ),
                  ),
                );
                if (result != null) {
                  _addSale(result);
                }
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'New Sale',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
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
}
