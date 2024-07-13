import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

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
}

LocalStorage localStorage = LocalStorage();
