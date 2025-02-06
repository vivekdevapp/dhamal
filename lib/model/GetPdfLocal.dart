import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf_render/pdf_render.dart';

class PdfScanner with ChangeNotifier {
  List<Map<String, dynamic>> _pdfFiles = []; // 📌 List of PDF Details
  bool _isLoading = false;

  List<Map<String, dynamic>> get pdfFiles => _pdfFiles;
  bool get isLoading => _isLoading;

  /// 📌 **1️⃣ SharedPreferences से सेव किए गए PDF पाथ लोड करें**
  Future<void> loadPdfPaths() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedPaths = prefs.getStringList('pdf_paths') ?? [];

    _pdfFiles = savedPaths.map((path) {
      return {
        'path': path,
        'size': getFileSize(path),
        'folder': getFolderName(path),
        'pages': 0,  // Pages बाद में Load होंगे
      };
    }).toList();

    // अब सभी PDFs के पेज नंबर निकालें
    for (var pdf in _pdfFiles) {
      pdf['pages'] = await getPdfPageCount(pdf['path']);
    }

    notifyListeners();
  }

  /// 📌 **2️⃣ PDF फाइल्स स्कैन करें और SharedPreferences में सेव करें**
  Future<void> scanAndSavePdfFiles(String directoryPath) async {
    _isLoading = true;
    notifyListeners();

    List<File> pdfFiles = await scanForPDFFiles(directoryPath);
    _pdfFiles = pdfFiles.map((file) {
      return {
        'path': file.path,
        'size': getFileSize(file.path),
        'folder': getFolderName(file.path),
        'pages': 0,  // Pages बाद में Load होंगे
      };
    }).toList();

    // अब सभी PDFs के पेज नंबर निकालें
    for (var pdf in _pdfFiles) {
      pdf['pages'] = await getPdfPageCount(pdf['path']);
    }

    // SharedPreferences में Save करें
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'pdf_paths',
      _pdfFiles.map<String>((pdf) => pdf['path'] as String).toList(),
    );


    _isLoading = false;
    notifyListeners();
  }

  /// 📌 **3️⃣ स्पेसिफिक डायरेक्ट्री में PDF सर्च करें**
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

  /// 📌 **4️⃣ रीफ्रेश करने पर नया डेटा स्कैन और अपडेट करें**
  Future<void> refreshPdfFiles(String directoryPath) async {
    await scanAndSavePdfFiles(directoryPath);
  }

  /// 📌 **5️⃣ PDF का Size (MB या KB) निकालने का फ़ंक्शन**
  String getFileSize(String filePath) {
    File file = File(filePath);
    int bytes = file.lengthSync();
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  /// 📌 **6️⃣ Folder Name निकालने का फ़ंक्शन**
  String getFolderName(String filePath) {
    return filePath.split('/')[filePath.split('/').length - 2]; // PDF के Parent Folder का नाम
  }

  /// 📌 **7️⃣ PDF में Total Pages निकालने का फ़ंक्शन**
  Future<int> getPdfPageCount(String filePath) async {
    try {
      final doc = await PdfDocument.openFile(filePath);
      return doc.pageCount;
    } catch (e) {
      print('Error getting page count: $e');
      return 0;
    }
  }
}
