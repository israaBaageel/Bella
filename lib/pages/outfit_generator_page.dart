import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OutfitGeneratorPage extends StatefulWidget {
  const OutfitGeneratorPage({super.key});

  @override
  _OutfitGeneratorPageState createState() => _OutfitGeneratorPageState();
}

class _OutfitGeneratorPageState extends State<OutfitGeneratorPage> {
  bool isLoading = false;
  Map<String, Map<String, dynamic>> weeklyOutfits = {}; // Store weekly outfits
  Map<String, String> dailyStyles = {}; // Store selected styles for each day
  String? selectedStyle; // Selected style for entire calendar generation

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Generated Outfits"),
        backgroundColor: Colors.pink[100],
      ),
      body: Column(
        children: [
          // Select Style for the entire calendar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Style for the Week',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
              ),
              items:
                  ['casual', 'formal', 'sporty']
                      .map(
                        (style) =>
                            DropdownMenuItem(value: style, child: Text(style)),
                      )
                      .toList(),
              value: selectedStyle,
              onChanged: (value) {
                setState(() {
                  selectedStyle = value;
                });
                print("Style selected for the entire week: $selectedStyle");
                generateWeeklyOutfits(); // Generate outfits for the entire week
              },
            ),
          ),

          // Weekly Calendar Layout with Dropdown Menu for each day of the week
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(7, (index) {
                  String day =
                      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index];
                  return Container(
                    width:
                        130, // Adjusted the width further for a more compact layout
                    height: 530,
                    margin: EdgeInsets.symmetric(
                      horizontal: 6,
                    ), // Reduced margin
                    padding: EdgeInsets.all(6), // Reduced padding
                    decoration: BoxDecoration(
                      color: Colors.white, // White background for the boxes
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ), // Thin white border
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            0.1,
                          ), // Light shadow effect
                          spreadRadius: 2, // Spread shadow to make it look 3D
                          blurRadius: 5, // Blur radius for the shadow effect
                          offset: Offset(0, 4), // Shadow direction
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          day,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ), // Smaller font size
                        ),
                        SizedBox(height: 6), // Reduced space
                        // Dropdown for style selection for each day
                        Container(
                          width: 80, // Shrinking the width more to fit better
                          child: DropdownButton<String>(
                            value: dailyStyles[day],
                            hint: Text("Style"), // Only show the default text
                            onChanged: (value) {
                              setState(() {
                                dailyStyles[day] = value!;
                              });
                              print("Style selected for $day: $selectedStyle");
                              generateDailyOutfit(
                                day,
                              ); // Generate outfit only for the selected day
                            },
                            items:
                                ['casual', 'formal', 'sporty'].map((style) {
                                  return DropdownMenuItem<String>(
                                    value: style,
                                    child: Text(style),
                                  );
                                }).toList(),
                          ),
                        ),
                        // Display generated outfit for each day
                        SizedBox(height: 6), // Reduced space
                        if (weeklyOutfits[day] != null)
                          buildOutfitCard(weeklyOutfits[day]!),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),

          // Generate button to regenerate outfits for the entire week
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: generateWeeklyOutfits,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[300],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Generate Weekly Outfits",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Generate outfits for the entire week when the user presses the regenerate button
  Future<void> generateWeeklyOutfits() async {
    setState(() {
      isLoading = true;
    });

    // If no outer style is selected, randomly choose a style
    if (selectedStyle == null || selectedStyle!.isEmpty) {
      List<String> styles = ['casual', 'formal', 'sporty'];
      selectedStyle =
          styles[(DateTime.now().millisecondsSinceEpoch % styles.length)];
      print("No style selected, using random style: $selectedStyle");
    } else {
      print("Selected Style for the entire week: $selectedStyle");
    }

    try {
      final user = FirebaseAuth.instance.currentUser;

      // Clear previous weekly outfits before regenerating
      setState(() {
        weeklyOutfits.clear();
      });

      // Reset daily styles to match the selected outer style
      for (var day in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']) {
        dailyStyles[day] =
            selectedStyle!; // Set all days to the selected outer style
      }

      // Generate outfits for each day based on the selected style for the entire week
      for (var day in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']) {
        final dayStyle = dailyStyles[day];

        if (dayStyle != null) {
          final String requestUrl =
              "http://10.0.2.2:5000/generate-outfit?uid=${user?.uid}&style=$dayStyle"; // GET method
          print("Request URL: $requestUrl");

          // Send the GET request
          final response = await http.get(Uri.parse(requestUrl));

          // Debugging the response status
          print("Response Status: ${response.statusCode}");
          print("Response Body: ${response.body}");

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            setState(() {
              weeklyOutfits[day] =
                  data['outfit']; // Store the result for each day
              isLoading = false;
            });
          } else {
            throw Exception(
              "Failed to regenerate outfit: ${response.statusCode}",
            );
          }
        }
      }
    } catch (e) {
      print("Error regenerating outfits: $e");
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to regenerate outfits. Please try again."),
          backgroundColor: Colors.red[400],
        ),
      );
    }
  }

  // Generate outfit for the selected day only
  Future<void> generateDailyOutfit(String day) async {
    setState(() {
      isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final dayStyle = dailyStyles[day] ?? selectedStyle;

      if (dayStyle != null) {
        final String requestUrl =
            "http://10.0.2.2:5000/generate-outfit?uid=${user?.uid}&style=$dayStyle"; // GET method
        print("Request URL for $day: $requestUrl");

        // Send the GET request
        final response = await http.get(Uri.parse(requestUrl));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            weeklyOutfits[day] =
                data['outfit']; // Store the result for the specific day
            isLoading = false;
          });
        } else {
          throw Exception("Failed to regenerate outfit for $day");
        }
      }
    } catch (e) {
      print("Error regenerating outfit for $day: $e");
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to regenerate outfit for $day. Please try again.",
          ),
          backgroundColor: Colors.red[400],
        ),
      );
    }
  }

  // Outfit Card to display each outfit part for the day
  Widget buildOutfitCard(Map<String, dynamic> outfit) {
    List<Widget> parts = [];

    // Add image parts to the UI only if they exist
    if (outfit.containsKey('dress') && outfit['dress'] != null) {
      parts.add(buildOutfitImage(outfit['dress']));
    }
    if (outfit.containsKey('top') && outfit['top'] != null) {
      parts.add(buildOutfitImage(outfit['top']));
    }
    if (outfit.containsKey('bottom') && outfit['bottom'] != null) {
      parts.add(buildOutfitImage(outfit['bottom']));
    }
    if (outfit.containsKey('shoes') && outfit['shoes'] != null) {
      parts.add(buildOutfitImage(outfit['shoes']));
    }

    return Card(
      elevation: 0, // No elevation for a flat look
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ...parts, // Display only images of the outfit parts
            ],
          ),
        ),
      ),
    );
  }

  // Updated buildOutfitImage method to display images with reduced vertical spacing
  Widget buildOutfitImage(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4.0,
      ), // Reduced vertical space between images
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          item['url'] ?? '',
          height: 120, // Medium size (adjust height to your preference)
          width: 120, // Medium size (adjust width to your preference)
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 80, // Smaller placeholder for error state
              width: double.infinity,
              color: Colors.grey[300],
              child: Center(
                child: Icon(
                  Icons.broken_image,
                  size: 48,
                  color: Colors.grey[600],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
