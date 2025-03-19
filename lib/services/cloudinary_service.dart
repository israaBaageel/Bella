import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<bool> uploadToCloudinary(FilePickerResult filePickerResult) async {
  print("Starting upload...");

  if (filePickerResult.files.isEmpty ||
      filePickerResult.files.single.path == null) {
    print("No file selected or file path is null");
    return false;
  }

  File file = File(filePickerResult.files.single.path!);
  print("File to upload: ${file.path}");

  // Load Cloudinary credentials
  String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

  if (cloudName.isEmpty || uploadPreset.isEmpty) {
    print("Cloudinary credentials are missing in .env file");
    return false;
  }

  // Cloudinary upload URL
  var uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/upload");

  // Create multipart request
  var request = http.MultipartRequest("POST", uri);

  // Attach the file
  var multipartFile = await http.MultipartFile.fromPath(
    'file',
    file.path,
    filename: file.path.split("/").last,
  );

  request.files.add(multipartFile);
  request.fields['upload_preset'] = uploadPreset;
  request.fields['resource_type'] = "auto"; // Auto-detect file type

  try {
    // Send request
    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    print("Cloudinary Response: $responseBody");

    return response.statusCode == 200;
  } catch (e) {
    print("Upload failed: $e");
    return false;
  }
}
