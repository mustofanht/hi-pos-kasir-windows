import 'dart:io';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class LocalStorage {
  Future<List<String>> saveImages(List<File> imageFiles) async {
    final directory = await getApplicationDocumentsDirectory();
    List<String> filePaths = [];

    for (File imageFile in imageFiles) {
      final fileName = path.basename(imageFile.path);
      final file = File('${directory.path}/$fileName');

      await imageFile.copy(file.path);

      filePaths.add(file.path);
    }

    return filePaths;
  }

  Future<List<File>> getImages(List<String> imagePaths) async {
    List<File> files = [];
    for (String imagePath in imagePaths) {
      files.add(File(imagePath));
    }
    return files;
  }

  Future<List<File>> getSavedImages() async {
    final directory = await getApplicationDocumentsDirectory();
    final imageDirectory = Directory(directory.path);
    List<File> imageFiles = [];
    List<FileSystemEntity> entities = await imageDirectory.list().toList();

    for (FileSystemEntity entity in entities) {
      if (entity is File && looksLikeImage(entity)) {
        imageFiles.add(entity);
      }
    }

    return imageFiles;
  }

  bool looksLikeImage(FileSystemEntity entity) {
    return entity.path.endsWith('.png') ||
        entity.path.endsWith('.jpg') ||
        entity.path.endsWith('.jpeg') ||
        entity.path.endsWith('.gif');
  }

  Future<Directory> _getAppDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory;
  }

  Future<void> downloadAndSaveImagePromo(
    String imageName,
    String imageUrl,
  ) async {
    logger.safeLog('URL : $imageUrl');
    final response = await http.get(
      Uri.parse(imageUrl),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      },
    );
    logger.safeLog('RESPONSE : ${response.statusCode}');
    logger.safeLog('RESPONSE : ${response.toString()}');
    if (response.statusCode == 200) {
      final imageBytes = response.bodyBytes;
      final directory = await _getAppDirectory();
      final imagePath = path.join(directory.path, imageName);
      final file = File(imagePath);

      if (await file.exists()) {
        await file.delete();
      }

      await file.writeAsBytes(imageBytes);
    } else {
      throw Exception('Failed to download image');
    }
  }
}

LocalStorage localStorage = LocalStorage();
