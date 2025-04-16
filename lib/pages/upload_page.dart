import 'dart:convert'; // Add this for json decoding
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:test/services/cloudinary_service2.dart'; // CloudinaryService2

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _image;
  Map<String, dynamic> _analysis = {}; // For storing clothing analysis
  Map<String, dynamic> _outfit = {}; // For storing outfit suggestions
  String? _imageUrl; // For storing Cloudinary image URL
  String _statusMessage = ''; // For user feedback
  final picker = ImagePicker();
  FilePickerResult? _filePickerResult;

  // Function to pick an image from gallery or camera
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _uploadImageAndDetect(); // Upload the image and detect clothing
    }
  }

  // Function to upload image and get prediction from the Flask backend
  Future<void> _uploadImageAndDetect() async {
    if (_image == null) return;

    setState(() {
      _statusMessage =
          'Uploading image and detecting...'; // Update status message to show loading
    });

    // Send the image for prediction to the Flask backend
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:5000/predict'), // Flask server URL
    );

    var multipartFile = await http.MultipartFile.fromPath(
      'image',
      _image!.path,
    );

    request.files.add(multipartFile);

    // Send the request to Flask server and get the response
    var response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      print("Response Data: $responseData"); // Debugging the response

      setState(() {
        final responseJson = jsonDecode(responseData);
        _analysis = responseJson['analysis'];
        _outfit = responseJson['outfit'];
        _imageUrl = responseJson['image_url']; // Get the Cloudinary URL
      });

      // Now display the detection results immediately
      setState(() {
        _statusMessage =
            'Detection complete! Now uploading to Cloudinary...'; // Change status
      });

      // Now upload the image and detected data to Cloudinary
      bool uploadSuccess = await _uploadToCloudinary();

      if (uploadSuccess) {
        setState(() {
          _statusMessage =
              'Upload successful! Image and prediction saved to Cloudinary.';
        });
      } else {
        setState(() {
          _statusMessage = 'Upload failed. Please try again.';
        });
      }
    } else {
      setState(() {
        _statusMessage = 'Error during detection. Please try again.';
        _analysis = {};
        _outfit = {};
        _imageUrl = null;
      });
    }
  }

  // Function to upload image and prediction result to Cloudinary
  Future<bool> _uploadToCloudinary() async {
    if (_image == null) return false;

    try {
      final cloudinaryService2 =
          CloudinaryService2(); // Create an instance of CloudinaryService2

      // Send image and detected data (analysis) to Cloudinary
      bool uploadResult = await cloudinaryService2.uploadImageWithMetadata(
        _image!,
        jsonEncode({
          'analysis': _analysis,
          'outfit': _outfit,
        }), // Send the metadata (detection data) as a JSON string
      );

      return uploadResult;
    } catch (e) {
      print('Error uploading to Cloudinary: $e'); // Debugging error
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload and Detect Fashion Item'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        // Make the content scrollable
        padding: const EdgeInsets.all(16.0),
        child: Center(
          // Center the content horizontally
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center horizontally
            children: [
              _image == null
                  ? Text("No image selected.")
                  : Image.file(_image!, height: 200, width: 200),
              SizedBox(height: 20),
              // Display the formatted result only if predictions exist
              _analysis.isEmpty
                  ? Container()
                  : Column(
                    children: [
                      Text(
                        "Clothing Analysis",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              Colors
                                  .pink[100], // Light pink color for the heading
                        ),
                      ),
                      Divider(color: Colors.grey), // Add a divider line
                      SizedBox(height: 10),
                      // Loop through each analysis result
                      ..._analysis.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            "${entry.key}: ${entry.value}",
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Colors
                                      .black, // Normal text color for answers (black)
                            ),
                          ),
                        );
                      }).toList(),
                      SizedBox(height: 20),
                      Text(
                        "Suggested Outfit",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              Colors
                                  .pink[100], // Light pink color for the heading
                        ),
                      ),
                      Divider(color: Colors.grey), // Add a divider line
                      SizedBox(height: 10),
                      // Loop through each outfit suggestion
                      ..._outfit.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            "${entry.key}: ${entry.value}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight
                                      .normal, // Keep the answers normal (not bold)
                              color:
                                  Colors
                                      .black, // Normal text color for answers (black)
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.pink[100], // Light pink color for the button
                ),
                child: Text("Pick Image from Gallery"),
              ),
              SizedBox(height: 20),
              // Display the Cloudinary image URL if it exists
              _imageUrl != null
                  ? Column(
                    children: [
                      Text(
                        "Uploaded Image from Cloudinary:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Image.network(
                        _imageUrl!,
                      ), // Display the image from Cloudinary
                    ],
                  )
                  : Container(),
              SizedBox(height: 20),
              // Display the status message
              _statusMessage.isNotEmpty
                  ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _statusMessage,
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
