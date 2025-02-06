import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PdfScanner with ChangeNotifier {
  List<String> _pdfPaths = [];
  bool _isLoading = false;

  List<String> get pdfPaths => _pdfPaths;
  bool get isLoading => _isLoading;

  /// 📌 **1️⃣ SharedPreferences से सेव किए गए PDF पाथ लोड करें**
  Future<void> loadPdfPaths() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _pdfPaths = prefs.getStringList('pdf_paths') ?? [];
    notifyListeners();  // 🔄 UI अपडेट करने के लिए
  }

  /// 📌 **2️⃣ PDF फाइल्स स्कैन करें और SharedPreferences में सेव करें**
  Future<void> scanAndSavePdfFiles(String directoryPath) async {
    _isLoading = true;
    notifyListeners();

    List<File> pdfFiles = await scanForPDFFiles(directoryPath);
    _pdfPaths = pdfFiles.map((file) => file.path).toList();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('pdf_paths', _pdfPaths);

    _isLoading = false;
    notifyListeners();  // 🔄 UI अपडेट करने के लिए
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
}
