import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OutfitGeneratorPage extends StatefulWidget {
  @override
  _OutfitGeneratorPageState createState() => _OutfitGeneratorPageState();
}

class _OutfitGeneratorPageState extends State<OutfitGeneratorPage> {
  bool isLoading = false;
  Map<String, dynamic> currentOutfit = {};

  // Style filter only
  String? selectedStyle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Generated Outfits"),
        backgroundColor: Colors.pink[100],
      ),
      body: Column(
        children: [
          // Style filter dropdown
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Select Style'),
              items: ['casual', 'formal', 'sporty']
                  .map((style) => DropdownMenuItem(value: style, child: Text(style)))
                  .toList(),
              value: selectedStyle,
              onChanged: (value) {
                setState(() {
                  selectedStyle = value;
                });
              },
            ),
          ),

          // Outfit display area
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.pink[300]))
                : currentOutfit.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.checkroom, size: 64, color: Colors.grey[400]),
                            SizedBox(height: 16),
                            Text("No outfit generated yet", style: TextStyle(fontSize: 18, color: Colors.grey[700])),
                            SizedBox(height: 8),
                            Text(
                              "Press the button below to generate an outfit",
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.all(16),
                        child: buildOutfitCard(currentOutfit),
                      ),
          ),

          // Generate button
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: generateOutfit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[300],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Generate Outfit", style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> generateOutfit() async {
    setState(() {
      isLoading = true;
    });

    try {
      final queryParams = {
        if (selectedStyle != null) 'style': selectedStyle!,
      };

      final uri = Uri.http('10.0.2.2:5000', '/generate-outfit', queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // Set the received outfit data directly
          currentOutfit = data; // No need to wrap with 'outfit'
          isLoading = false;
        });
      } else {
        throw Exception("Failed to generate outfit: ${response.statusCode}");
      }
    } catch (e) {
      print("Error generating outfit: $e");
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to generate outfit. Please try again."),
          backgroundColor: Colors.red[400],
        ),
      );
    }
  }

Widget buildOutfitCard(Map<String, dynamic> outfit) {
  List<Widget> parts = [];

  // Add parts to the UI only if they exist
  if (outfit.containsKey('dress') && outfit['dress'] != null) {
    parts.add(OutfitItemTile(label: "Dress", data: outfit['dress']));
  }
  if (outfit.containsKey('top') && outfit['top'] != null) {
    parts.add(OutfitItemTile(label: "Top", data: outfit['top']));
  }
  if (outfit.containsKey('bottom') && outfit['bottom'] != null) {
    parts.add(OutfitItemTile(label: "Bottom", data: outfit['bottom']));
  }
  if (outfit.containsKey('shoes') && outfit['shoes'] != null) {
    parts.add(OutfitItemTile(label: "Shoes", data: outfit['shoes']));
  }

  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Outfit",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pink[300]),
          ),
          Divider(color: Colors.grey[300]),
         // SizedBox(height: 2),
          ...parts, // This will only render available outfit parts
        ],
      ),
    ),
  );
}

}

class OutfitItemTile extends StatelessWidget {
  final String label;
  final Map<String, dynamic> data;

  const OutfitItemTile({required this.label, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            data['url'] ?? '',
            height: 230,
            width: 250,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 100,
                width: double.infinity,
                color: Colors.grey[300],
                child: Center(child: Icon(Icons.broken_image, size: 48, color: Colors.grey[600])),
              );
            },
          ),
        ),
        SizedBox(height: 8),
        Text('Type: ${data['type'] ?? 'Unknown'}', style: TextStyle(fontSize: 16)),
        Text('Color: ${data['color'] ?? 'Unknown'}', style: TextStyle(fontSize: 16)),
        Text('Style: ${data['style'] ?? 'Unknown'}', style: TextStyle(fontSize: 16)),
        SizedBox(height: 16),
      ],
    );
  }
}
