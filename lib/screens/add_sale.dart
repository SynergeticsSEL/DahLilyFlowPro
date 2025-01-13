import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddSalePage extends StatefulWidget {
  final Function(Map<String, String>) onAddSale;

  const AddSalePage({super.key, required this.onAddSale});

  @override
  _AddSalePageState createState() => _AddSalePageState();
}

class _AddSalePageState extends State<AddSalePage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _saleData = {
    'saleID': '',
    'customerName': '',
    'productName': '',
    'saleStatus': '',
    'items': '',
  };

  final CollectionReference salesCollection =
      FirebaseFirestore.instance.collection('sales');

  Future<void> _addSaleToFirestore() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      int itemsCount = int.parse(_saleData['items'] ?? '0'); // Handle null safely

      try {
        await salesCollection.add({
          'saleID': _saleData['saleID'],
          'date': DateTime.now().toString().split(' ')[0], // Store current date
          'customer': _saleData['customerName'],
          'product': _saleData['productName'],
          'items': itemsCount,
          'status': _saleData['saleStatus'],
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sale added successfully!')),
        );

        Navigator.pop(context); // Go back to Sales page
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add sale: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5EF),
      appBar: AppBar(
        title: const Text('New Sale', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4E342E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Sale ID'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the Sale ID';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _saleData['saleID'] = value!;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Items Sold'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the number of items sold';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _saleData['items'] = value!;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Customer Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Customer Name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _saleData['customerName'] = value!;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Product Name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _saleData['productName'] = value!;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
  decoration: const InputDecoration(labelText: 'Sale Status'),
  value: null,  // Start with no selection
  items: const [
    DropdownMenuItem(value: 'Completed', child: Text('Completed')),
    DropdownMenuItem(value: 'Pending', child: Text('Pending')),
  ],
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please select the Sale Status';
    }
    return null;
  },
  onChanged: (value) {
    setState(() {
      _saleData['saleStatus'] = value!;
    });
  },
),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4E342E),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4E342E),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _addSaleToFirestore,
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}