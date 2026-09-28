import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  final String cloudName;
  final String uploadPreset;

  const CloudinaryService({
    required this.cloudName,
    required this.uploadPreset,
  });

  Future<String> uploadImage(File imageFile) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Image upload failed. Please try again.');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final secureUrl = json['secure_url'] as String?;

    if (secureUrl == null) {
      throw Exception('Unexpected upload response.');
    }

    return secureUrl;
  }

  Future<List<String>> uploadImages(List<File> imageFiles) async {
    final uploads = imageFiles.map((file) => uploadImage(file));
    return Future.wait(uploads);
  }
}
