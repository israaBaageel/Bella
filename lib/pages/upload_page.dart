import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:test/services/cloudinary_service2.dart'; // CloudinaryService2
import 'package:test/services/database_service.dart'; // Assuming this is for DB integration

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _image;
  String _result = "No result yet";
  final picker = ImagePicker();
  FilePickerResult? _filePickerResult;

  // Function to pick an image from gallery or camera
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _uploadImageAndDetect();
    }
  }

  // Function to upload image and get prediction from the Flask backend
  Future<void> _uploadImageAndDetect() async {
    if (_image == null) return;

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
      setState(() {
        _result = "Prediction: $responseData";
      });
      // After detecting the clothing items, upload the image and prediction result to Cloudinary
      _uploadToCloudinary(responseData);
    } else {
      setState(() {
        _result = "Error: Unable to get prediction.";
      });
    }
  }

  // Function to upload image and prediction result to Cloudinary
  Future<void> _uploadToCloudinary(String detectedData) async {
    if (_image == null) return;

    final cloudinaryService2 =
        CloudinaryService2(); // Create an instance of CloudinaryService2

    bool uploadResult = await cloudinaryService2.uploadImageWithMetadata(
      _image!,
      detectedData,
    ); // Call instance method

    if (uploadResult) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image and prediction uploaded to Cloudinary")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload image and prediction")),
      );
    }
  }

  // Function to open the file picker and allow selecting files (if required)
  void _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      allowedExtensions: ["jpg", "jpeg", "png", "jfif", "mp4"],
      type: FileType.custom,
    );

    if (result != null) {
      setState(() {
        _filePickerResult = result;
        _image = File(
          result.files.single.path!,
        ); // Set the selected file as image
      });
      _uploadImageAndDetect();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload and Detect Fashion Item'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null
                ? Text("No image selected.")
                : Image.file(_image!, height: 200, width: 200),
            SizedBox(height: 20),
            Text(
              _result,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text("Pick Image from Gallery"),
            ),
            SizedBox(height: 20),
            // Add the file picker button if you need to allow other file formats
            ElevatedButton(
              onPressed: _openFilePicker,
              child: Text("Pick Image from File Picker"),
            ),
          ],
        ),
      ),
    );
  }
}
