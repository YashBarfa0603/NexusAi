import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

class PickedFileResult {
  final String path;
  final String name;
  final String mimeType;
  final int sizeBytes;

  const PickedFileResult({
    required this.path,
    required this.name,
    required this.mimeType,
    required this.sizeBytes,
  });
}

class FilePickerService {
  final ImagePicker _imagePicker = ImagePicker();
  // max 4 MB image
  static const int maxImageSizeBytes = 4 * 1024 * 1024; 
  static const int maxDocSizeBytes = 4 * 1024 * 1024;  

  
  Future<PickedFileResult?> pickImageFromGallery() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1920,
      maxHeight: 1920,
    );
    return _processXFile(image);
  }


  Future<PickedFileResult?> takePhoto() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1920,
      maxHeight: 1920,
    );
    return _processXFile(image);
  }


  Future<PickedFileResult?> pickDocument() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'csv', 'xlsx', 'pptx'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    if (file.path == null) return null;

    final sizeBytes = file.size;
    if (sizeBytes > maxDocSizeBytes) {
      throw Exception(
        'File too large (${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB). '
        'Maximum allowed is ${maxDocSizeBytes ~/ (1024 * 1024)}MB.',
      );
    }

    final mime = lookupMimeType(file.path!) ?? 'application/octet-stream';

    return PickedFileResult(
      path: file.path!,
      name: file.name,
      mimeType: mime,
      sizeBytes: sizeBytes,
    );
  }

  Future<PickedFileResult?> _processXFile(XFile? xFile) async {
    if (xFile == null) return null;

    final file = File(xFile.path);
    final sizeBytes = await file.length();

    if (sizeBytes > maxImageSizeBytes) {
      throw Exception(
        'Image too large (${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB). '
        'Maximum allowed is ${maxImageSizeBytes ~/ (1024 * 1024)}MB.',
      );
    }

    final mime = lookupMimeType(xFile.path) ?? 'image/jpeg';

    return PickedFileResult(
      path: xFile.path,
      name: xFile.name,
      mimeType: mime,
      sizeBytes: sizeBytes,
    );
  }
}
