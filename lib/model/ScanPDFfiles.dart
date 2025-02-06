import 'dart:io';

Future<List<File>> scanForPDFFiles(String directoryPath) async {
  List<File> pdfFiles = [];
  Directory directory = Directory(directoryPath);

  Future<void> scanDirectory(Directory dir) async {
    try {
      await for (var entity in dir.list(recursive: false, followLinks: false)) {
        if (entity is File && entity.path.endsWith('.pdf')) {
          pdfFiles.add(entity);
        } else if (entity is Directory) {
          await scanDirectory(entity);
        }
      }
    } catch (e) {
      print('Error while scanning directory: $e');
    }
  }

  await scanDirectory(directory);
  return pdfFiles;
}