import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:test/services/database_service.dart';

class CloudinaryService2 {
  // Upload image with metadata (including prediction result)
  Future<bool> uploadImageWithMetadata(File file, String detectedData) async {
    print("Starting upload with metadata...");

    // Load Cloudinary credentials from environment variables
    String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
    String apiKey = dotenv.env['CLOUDINARY_API_KEY'] ?? '';
    String apiSecret = dotenv.env['CLOUDINARY_SECRET_KEY'] ?? '';
    String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

    if (cloudName.isEmpty ||
        apiKey.isEmpty ||
        apiSecret.isEmpty ||
        uploadPreset.isEmpty) {
      print("Cloudinary credentials are missing in .env file");
      return false;
    }

    // Generate timestamp
    int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Generate the string to sign for signature
String toSign =
    "auto_tagging=0.8&categorization=imagga_tagging&tags=$detectedData&timestamp=$timestamp&upload_preset=$uploadPreset$apiSecret";


    // Generate SHA-1 signature using the API secret and string to sign
    var bytes = utf8.encode(toSign);
    var digest = sha1.convert(bytes);
    String signature = digest.toString();

    // Cloudinary upload URL
    var uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    // Create multipart request
    var request = http.MultipartRequest("POST", uri);

    // Attach the file
    var multipartFile = await http.MultipartFile.fromPath(
      'file',
      file.path,
      filename: file.path.split("/").last,
    );
    request.files.add(multipartFile);
    request.fields['api_key'] = apiKey;
    request.fields['timestamp'] = timestamp.toString();
    request.fields['signature'] = signature;
    request.fields['upload_preset'] = uploadPreset;
    request.fields['resource_type'] = "image"; // Auto-detect file type
    request.fields['categorization'] = "imagga_tagging"; // Enable auto-tagging
    request.fields['auto_tagging'] = "0.8"; // Confidence threshold
    request.fields['tags'] =
        detectedData; // Add prediction result as metadata (tags)

    // Send request
    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    // Print response
    print("Cloudinary Response: $responseBody");

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(responseBody);
      Map<String, String> requiredData = {
        "name": file.path.split("/").last,
        "id": jsonResponse["public_id"],
        "extension": file.path.split(".").last,
        "size": jsonResponse["bytes"].toString(),
        "url": jsonResponse["secure_url"],
        "created_at": jsonResponse["created_at"],
      };

      // Save metadata to database
      await AppDatabaseService().saveUploadFilesData(requiredData);
      print("Upload successful!");
      return true;
    } else {
      print("Upload failed with status: ${response.statusCode}");
      print("Response body: $responseBody");
      return false;
    }
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
      "Failed to delete the file, status: \${response.statusCode} : \${response.reasonPhrase}",
    );
    return false;
  }
}
