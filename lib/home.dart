import 'package:flutter/material.dart';
import 'add_item.dart';
import 'shopping_list.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping List')),
      body: const ShoppingList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddItem()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}