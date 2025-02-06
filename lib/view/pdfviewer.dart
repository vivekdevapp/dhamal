import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfPath;

  PdfViewerScreen({required this.pdfPath});

  @override
  _PdfViewerScreenState createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late PdfViewerController _pdfViewerController;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📖 PDF Viewer', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              _pdfViewerController.previousPage();
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios),
            onPressed: () {
              _pdfViewerController.nextPage();
            },
          ),
        ],
      ),
      body: SfPdfViewer.file(
        File(widget.pdfPath),
        controller: _pdfViewerController,
      ),
    );
  }
}
