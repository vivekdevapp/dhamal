import 'package:flutter/material.dart';
import 'package:pdfz/view/pdfviewer.dart';
import 'package:provider/provider.dart';
import '../model/GetPdfLocal.dart';

class PdfListScreen extends StatefulWidget {
  @override
  _PdfListScreenState createState() => _PdfListScreenState();
}

class _PdfListScreenState extends State<PdfListScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<PdfScanner>(context, listen: false).loadPdfPaths();
  }

  @override
  Widget build(BuildContext context) {
    final pdfProvider = Provider.of<PdfScanner>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('📚 My PDFs', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await pdfProvider.refreshPdfFiles('/storage/emulated/0/');
        },
        child: pdfProvider.isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.redAccent))
            : pdfProvider.pdfFiles.isEmpty
            ? Center(child: Text('No PDFs found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
            : ListView.builder(
          itemCount: pdfProvider.pdfFiles.length,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemBuilder: (context, index) {
            final pdf = pdfProvider.pdfFiles[index];
            final pdfName = pdf['path'].split('/').last;
            final folderName = pdf['folder'];
            final pagesNumber = pdf['pages'];
            final size = pdf['size'];

            return Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: EdgeInsets.all(12),
                leading: Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 40),
                title: Text(pdfName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text("📂 Folder: $folderName", style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                    Text("📄 Pages: $pagesNumber", style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                    Text("💾 Size: $size", style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                  ],
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (context)=>PdfViewerScreen(pdfPath: pdf['path'])));
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
