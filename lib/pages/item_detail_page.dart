import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ItemDetailPage extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> itemData;

  const ItemDetailPage({Key? key, required this.docId, required this.itemData})
    : super(key: key);

  Future<void> donateItem(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final donatedRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('donatedItems');

    final clothingRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('clothingItems')
        .doc(docId);

    try {
      await donatedRef.add(itemData);
      await clothingRef.delete();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Item donated successfully!")));
      Navigator.pop(context); // Return to profile after donation
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error donating item: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = itemData['url'] ?? '';

    return Scaffold(
      appBar: AppBar(title: Text("Item Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (imageUrl.isNotEmpty) Image.network(imageUrl, height: 300),

            const SizedBox(height: 16),
            Text("Type: ${itemData['type'] ?? 'Unknown'}"),
            Text("Color: ${itemData['color'] ?? 'Unknown'}"),
            Text("Style: ${itemData['style'] ?? 'Unknown'}"),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () async {
                await donateItem(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[200],
              ),
              child: Text("Donate"),
            ),
          ],
        ),
      ),
    );
  }
}
