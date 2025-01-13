import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _productData = {
    'productID': '',
    'productName': '',
    'productInstruction': '',
    'amount': '',
  };

  // Firestore instance
  final CollectionReference _productsCollection =
      FirebaseFirestore.instance.collection('products');

  Future<void> _addProductToFirestore() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        await _productsCollection.add({
          'productID': _productData['productID'],
          'productName': _productData['productName'],
          'productInstruction': _productData['productInstruction'],
          'amount': _productData['amount'],
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully!')),
        );

        Navigator.pop(context); // Go back to Products page
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5EF),
      appBar: AppBar(
        title: const Text('New Product', style: TextStyle(color: Colors.white)),
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
                      decoration: const InputDecoration(labelText: 'Product ID'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the Product ID';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _productData['productID'] = value!;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Amount of Item'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the amount';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _productData['amount'] = value!;
                      },
                    ),
                  ),
                ],
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
                  _productData['productName'] = value!;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Product Instruction'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Product Instruction';
                  }
                  return null;
                },
                onSaved: (value) {
                  _productData['productInstruction'] = value!;
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
                    onPressed: _addProductToFirestore,
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
