import 'dart:io';
import 'package:jaya_propertiy/app/utils/common/logger_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class LocalStorage {
  static String promoDir = 'PROMO';

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

  String getFileNameFromUrl(String url) {
    Uri uri = Uri.parse(url);
    return uri.pathSegments.last;
  }

  Future<Directory> _getAppDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory;
  }

  Future<void> deleteDirectory(Directory dir) async {
  if (await dir.exists()) {
    final List<FileSystemEntity> entities = dir.listSync();
    for (FileSystemEntity entity in entities) {
      if (entity is File) {
        await entity.delete();
      } else if (entity is Directory) {
        await deleteDirectory(entity);
      }
    }
    await dir.delete();
  }
}

  Future<void> downloadAndSaveImagePromo(String imageUrl) async {
    if (imageUrl.isNotEmpty) {
      logger.safeLog('URL : $imageUrl');
      Uri? uri = Uri.tryParse(imageUrl);
      logger.safeLog('URI : ${uri?.host}');
      logger.safeLog('URI : ${uri?.port}');
      logger.safeLog('URI : ${uri?.path}');
      if (uri == null || !uri.hasAbsolutePath) {
        logger.safeLog('Invalid URL: $imageUrl');
      }

      final response = await http.get(
        uri!,
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, seperti Gecko) Chrome/91.0.4472.124 Safari/537.36',
        },
      );

      logger.safeLog('STATUS CODE : ${response.statusCode}');
      if (response.statusCode == 200) {
        final imageBytes = response.bodyBytes;
        final directory = await _getAppDirectory();
        final finalDir = path.join(directory.path, promoDir);

        final dir = Directory(finalDir);

        if (await dir.exists()) await deleteDirectory(dir);

        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }

        final imagePath = path.join(
          finalDir,
          getFileNameFromUrl(imageUrl),
        );
        logger.safeLog('finalDir : $finalDir');
        logger.safeLog('DIR : $directory');
        logger.safeLog('PATH : $imagePath');
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

  Future<List<File>> getImagesPromoLocal() async {
    final directory = await _getAppDirectory();
    final finalDir = path.join(directory.path, promoDir);
    final imageDirectory = Directory(finalDir);
    List<File> imageFiles = [];
    if (await imageDirectory.exists()) {
      List<FileSystemEntity> entities = await imageDirectory.list().toList();
      for (FileSystemEntity entity in entities) {
        if (entity is File && looksLikeImage(entity)) {
          imageFiles.add(entity);
        }
      }
    }
    return imageFiles;
  }
}

LocalStorage localStorage = LocalStorage();
