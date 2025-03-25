import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:test/services/db_serivce.dart';


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
  var uri = Uri.parse("https://api.cloudinary.com/v1_1/dtqgjbewx/upload");

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

    // Send request
    var response = await request.send();
    // Get response
    var responseBody = await response.stream.bytesToString();

  // print response
  print("Cloudinary Response: $responseBody");

  if (response.statusCode == 200) {
    var jsonResponse = jsonDecode(responseBody);
    Map<String, String> requiredData = {
      "name": filePickerResult.files.first.name,
      "id": jsonResponse["public_id"],
      "extension": filePickerResult.files.first.extension!,
      "size": jsonResponse["bytes"].toString(),
      "url": jsonResponse["secure_url"],
      "created_at": jsonResponse["created_at"],
    };

    await DbService().saveUploadFilesData(requiredData);
    print("Upload successful!");
    return true;
  } else {
    print("Upload failed with status: ${response.statusCode}");
    return false;
  }
}

// delete specific file from cloudinary
Future<bool> deleteFromCloudinary(String publicId) async {
  // Cloudinary details
  String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? ''; 
  String apiKey = dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  String apiSecret = dotenv.env['CLOUDINARY_SECRET_KEY'] ?? '';

  // Generate the timestamp
  int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  // Prepare the string for signature generation
  String toSign = 'public_id=$publicId&timestamp=$timestamp$apiSecret';

  // Generate the signature using SHA1
  var bytes = utf8.encode(toSign);
  var digest = sha1.convert(bytes);
  String signature = digest.toString();
  // Prepare the request URL
  var uri = Uri.parse(
    'https://api.cloudinary.com/v1_1/$cloudName/raw/destroy/',
  );

  // Create the request
  var response = await http.post(
    uri,
    body: {
      'public_id': publicId,
      'timestamp': timestamp.toString(),
      'api_key': apiKey,
      'signature': signature,
    },
  );

  if (response.statusCode == 200) {
    var responseBody = jsonDecode(response.body);
    print(responseBody);
    if (responseBody['result'] == 'ok') {
      print("File deleted successfully.");
      return true;
    } else {
      print("Failed to delete the file.");
      return false;
    }
  } else {
    print(
      "Failed to delete the file, status: ${response.statusCode} : ${response.reasonPhrase}",
    );
    return false;
  }
}

