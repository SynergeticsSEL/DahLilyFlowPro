import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_product.dart';
import 'profile_page.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductsPage extends StatefulWidget {
  final User user;
  final String role;
  final String firstName;
  final String lastName;
  final String phoneNumber;

  const ProductsPage({
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
      builder: (context) => ProductsPage(
        user: user,
        role: role,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      ),
    );
  }

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final CollectionReference productsCollection =
      FirebaseFirestore.instance.collection('products');

  String searchQuery = ''; // Holds the search query

  void _editItemAmount(String docId, dynamic currentAmount) {
  final int amountAsInt = currentAmount is int
      ? currentAmount
      : int.tryParse(currentAmount.toString()) ?? 0;

  final TextEditingController amountController =
      TextEditingController(text: amountAsInt.toString());

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFFF9F5EF), 
        title: const Text(
          'Edit Item Amount',
          style: TextStyle(color: Colors.black),
        ),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Enter new amount',
            labelStyle: TextStyle(color: Colors.black54),
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF4E342E), // Brown color
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white), // White font
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF4E342E), // Brown color
            ),
            onPressed: () {
              final newAmount = int.tryParse(amountController.text);
              if (newAmount != null) {
                productsCollection.doc(docId).update({'amount': newAmount});
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid amount entered')),
                );
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white), // White font
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
        backgroundColor: const Color(0xFF4E342E), // Dark brown
        title: const Text('In Stock', style: TextStyle(color: Colors.white)),
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
                        searchQuery = value; // Update search query
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by Product ID',
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
                  stream: productsCollection.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(
                          child: Text('Error fetching products'));
                    }
                    final products = snapshot.data?.docs ?? [];
                    final filteredProducts = products.where((doc) {
                      final productID = (doc['productID'] ?? '').toString();
                      return productID
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase());
                    }).toList();

                    return DataTable(
                      headingRowColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 179, 174, 168)),
                      columns: const [
                        DataColumn(label: Text('Actions')),
                        DataColumn(label: Text('Product ID')),
                        DataColumn(label: Text('Product Name')),
                        DataColumn(label: Text('Instruction')),
                        DataColumn(label: Text('Items')),
                      ],
                      rows: filteredProducts.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return DataRow(
                          cells: [
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    productsCollection.doc(doc.id).delete();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () {
                                    _editItemAmount(
                                        doc.id, data['amount'] ?? 0);
                                  },
                                ),
                              ],
                            )),
                            DataCell(Text(data['productID'] ?? 'N/A')),
                            DataCell(Text(data['productName'] ?? 'N/A')),
                            DataCell(Text(data['productInstruction'] ?? 'N/A')),
                            DataCell(Text(data['amount']?.toString() ?? 'N/A')),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddProductPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add New',
                style: TextStyle(color: Colors.white),
              ),
            ),
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
