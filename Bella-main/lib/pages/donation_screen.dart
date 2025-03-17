import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DonationScreen extends StatelessWidget {
  final List<String> selectedItems; // List of selected items for donation

  DonationScreen({required this.selectedItems});

  Future<void> _launchAwonPlatform(BuildContext context) async {
    print('Attempting to launch Awon platform...');
    const url = 'https://awonksa.com/pr_university/';
    if (await canLaunch(url)) {
      print('Launching URL: $url');
      await launch(url);
    } else {
      print('Failed to launch URL: $url');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open Awon platform. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 255, 209, 224), // Pink
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade500,
                offset: Offset(4.0, 4.0),
                blurRadius: 3.0,
                spreadRadius: 1.0,
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              'lib/images/Awon.jpg', // Path to your Awon logo
              height: 60,
              width: 180,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected Items for Donation:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            if (selectedItems.isEmpty)
              Text('No items selected for donation.')
            else
              Column(
                children:
                    selectedItems.map((item) {
                      return Card(child: ListTile(title: Text(item)));
                    }).toList(),
              ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed:
                    () => _launchAwonPlatform(context), // Pass context here
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 255, 209, 224), // Pink
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Row(
                  mainAxisSize:
                      MainAxisSize
                          .min, // Ensure the row doesn't take up extra space
                  children: [
                    Image.asset(
                      'lib/images/Awon.jpg', // Path to your Awon logo
                      height: 24, // Adjust height as needed
                      width: 24, // Adjust width as needed
                    ),
                    SizedBox(width: 8), // Add spacing between logo and text
                    Text('Donate Now', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
