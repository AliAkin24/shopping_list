import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String baseURL = 'aliakin.atwebpages.com';

class ShoppingList extends StatefulWidget {
  const ShoppingList({super.key});

  @override
  State<ShoppingList> createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  List _items = [];

  @override
  void initState() {
    super.initState();
    fetchItems();
  }


  Future<void> fetchItems() async {
    final url = Uri.http(baseURL, 'getItems.php');
    print("Requesting URL: $url");

    try {
      final response = await http.get(url);
      print("Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        setState(() {
          _items = jsonDecode(response.body);
        });
      } else {
        print("Error: Response status is not 200.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load items. Please try again later.')),
        );
      }
    } catch (e) {
      print("Exception caught: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network request failed. Please check your connection.')),
      );
    }
  }


  Future<void> updateItemPurchased(int id, bool purchased) async {
    print("Updating item: ID = $id, Purchased = $purchased");

    final url = Uri.http(baseURL, 'updateItem.php');
    print("Requesting URL: $url with body: { 'id': $id, 'purchased': ${purchased ? '1' : '0'} }");

    try {
      final response = await http.post(url, body: {
        'id': id.toString(),
        'purchased': purchased ? '1' : '0',
      });

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          print("Item updated successfully.");
          fetchItems();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['error'] ?? 'Update failed')),
          );
        }
      } else {
        print("Error: Response status is not 200.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update item. Please try again later.')),
        );
      }
    } catch (e) {
      print("Exception caught: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network request failed. Please check your connection.')),
      );
    }
  }


  Future<void> deleteItem(int id) async {
    final url = Uri.http(baseURL, 'deleteItem.php');
    print("Requesting URL: $url with body: { 'id': $id }");

    try {
      final response = await http.post(url, body: {'id': id.toString()});
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          fetchItems();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['error'] ?? 'Deletion failed')),
          );
        }
      } else {
        print("Error: Response status is not 200.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete item. Please try again later.')),
        );
      }
    } catch (e) {
      print("Exception caught: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network request failed. Please check your connection.')),
      );
    }
  }


  void showDeleteConfirmationDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Item"),
          content: const Text("Are you sure you want to delete this item?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                deleteItem(id);
                Navigator.of(context).pop();
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return ListTile(
          title: Text(item['name']),
          subtitle: Text('${item['quantity']}  (${item['category']})'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: item['purchased'] == '1',
                onChanged: (bool? value) {
                  setState(() {
                    item['purchased'] = value! ? '1' : '0';
                  });
                  updateItemPurchased(int.parse(item['id']), value!);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  showDeleteConfirmationDialog(int.parse(item['id']));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
