import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  Future<String?> uploadToCloudinary(File file) async {
    try {
      String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
      String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

      if (cloudName.isEmpty || uploadPreset.isEmpty) {
        throw Exception("Cloudinary credentials are missing in .env file");
      }

      var uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/upload");
      var request = http.MultipartRequest("POST", uri);

      var multipartFile = await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: file.path.split("/").last,
      );

      request.files.add(multipartFile);
      request.fields['upload_preset'] = uploadPreset;
      request.fields['resource_type'] = "auto";

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return jsonResponse['secure_url'];
      } else {
        throw Exception("Upload failed: ${jsonResponse['error']['message']}");
      }
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }

  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
      final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];

      if (cloudName == null || uploadPreset == null) {
        throw Exception("Cloudinary credentials not configured");
      }

      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      );

      final request =
          http.MultipartRequest('POST', uri)
            ..fields['upload_preset'] = uploadPreset
            ..fields['public_id'] = 'profile_$userId'
            ..files.add(
              await http.MultipartFile.fromPath('file', imageFile.path),
            );

      final response = await request.send();

      if (response.statusCode != 200) {
        throw Exception("Upload failed with status ${response.statusCode}");
      }

      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      return jsonResponse['secure_url'] as String?;
    } catch (e) {
      debugPrint("Cloudinary upload error: $e");
      return null;
    }
  }
}
