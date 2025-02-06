import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../model/ScanPDFfiles.dart';

class GetPdf extends ChangeNotifier {
  final List<File> _pdffiles = [];
  final StreamController<File> _fileStreamController = StreamController<File>();
  bool _loading = false;

  List<File> get pdffiles => List.unmodifiable(_pdffiles);
  bool get isloading => _loading;
  Stream<File> get fileStream => _fileStreamController.stream;

  /// Fetches all PDF files asynchronously
  Future<void> fetchPdfFiles() async {
    _loading = true;
    notifyListeners();

    if (await _requestStoragePermission()) {
      try {
        // Run the scanning process in a separate isolate
        List<File> files = await compute(scanForPDFFiles, '/storage/emulated/0/');
        _pdffiles.addAll(files);
        for (var file in files) {
          _fileStreamController.add(file); // Stream each file to the UI
        }
      } catch (e) {
        print('Error fetching PDF files: $e');
      }
    } else {
      print('Storage permission denied.');
    }

    _loading = false;
    notifyListeners();
  }

  /// Requests storage permission
  Future<bool> _requestStoragePermission() async {
    var status = await Permission.storage.request();
    return status.isGranted;
  }

  @override
  void dispose() {
    _fileStreamController.close();
    super.dispose();
  }
}

/// Scans directories for PDF files in a background isolate

