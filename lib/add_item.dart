import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'home.dart'; 
const String baseURL = 'aliakin.atwebpages.com';

class AddItem extends StatelessWidget {
  const AddItem({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final categoryController = TextEditingController();

    Future<void> addItem() async {
      final url = Uri.http(baseURL, 'addItem.php');

      final response = await http.post(url, body: {
        'name': nameController.text,
        'quantity': quantityController.text,
        'category': categoryController.text,
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
                (Route<dynamic> route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['error'] ?? 'Unknown error')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add item. Please try again later.')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add Item')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: quantityController, decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number),
            TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: addItem, child: const Text('Add')),
          ],
        ),
      ),
    );
  }
}