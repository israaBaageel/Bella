import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:test/services/cloudinary_service.dart';
import 'package:test/services/cloudinary_service2.dart';

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  FilePickerResult? _filePickerResult;

  void _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      allowedExtensions: ["jpg", "jpeg", "png", "jfif", "mp4"],
      type: FileType.custom,
    );

    if (result != null) {
      setState(() {
        _filePickerResult = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedFile = _filePickerResult;

    return Scaffold(
      appBar: AppBar(title: Text('Upload Images'), centerTitle: true),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              selectedFile != null
                  ? "File selected: ${selectedFile.files.single.name}"
                  : 'Tap the button to upload images',
            ),
          ),

          SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (selectedFile == null || selectedFile.files.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("No file selected!")),
                      );
                      return;
                    }

                    final result = await uploadToCloudinary2(selectedFile);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          result
                              ? "File uploaded successfully."
                              : "Cannot upload your file!",
                        ),
                      ),
                    );
                  },
                  child: Text("Upload"),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openFilePicker,
        child: Icon(Icons.upload),
      ),
    );
  }
}
 