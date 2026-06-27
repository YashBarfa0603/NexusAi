import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ChatService {
  static String get baseUrl {
  if (kIsWeb) {
    return 'http://localhost:8000';
  }

  try {
    if (Platform.isAndroid) {
      // Replace <YOUR_LOCAL_IP> with your computer's local IP
      return 'http://<YOUR_LOCAL_IP>:8000';
    }
  } catch (_) {}

  return 'http://localhost:8000';
}

  
  Future<String> sendMessage(String message) async {
    if (message.trim().isEmpty) {
      throw Exception('Message cannot be empty.');
    }

    final url = Uri.parse('$baseUrl/chat');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'message': message,
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['reply'] != null) {
          return data['reply'];
        } else {
          throw Exception('Invalid response from server.');
        }
      } else {
        throw Exception(
          'Server Error (${response.statusCode}): ${response.body}',
        );
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on http.ClientException catch (e) {
      throw Exception('Network Error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  
  Future<String> sendMessageWithFile({
    required String message,
    required String filePath,
    required String fileType, 
  }) async {
    final url = Uri.parse('$baseUrl/chat-with-file');

    try {
      final request = http.MultipartRequest('POST', url);

      
      request.fields['message'] = message;
      request.fields['type'] = fileType;

      
      final mimeStr = lookupMimeType(filePath) ?? 'application/octet-stream';
      final mimeParts = mimeStr.split('/');

  
      final file = await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: MediaType(mimeParts[0], mimeParts[1]),
      );
      request.files.add(file);

      
      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 120),
          );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['reply'] != null) {
          return data['reply'];
        } else {
          throw Exception('Invalid response from server.');
        }
      } else {
        throw Exception(
          'Server Error (${response.statusCode}): ${response.body}',
        );
      }
    } on TimeoutException {
      throw Exception('Request timed out. File processing may take longer.');
    } on SocketException catch (e) {
      throw Exception('Network Error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to send file: $e');
    }
  }
}
