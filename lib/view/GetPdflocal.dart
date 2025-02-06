import 'package:flutter/material.dart';
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
    // 📌 ऐप स्टार्ट होते ही पहले से सेव किए हुए PDF पाथ लोड करें
    Provider.of<PdfScanner>(context, listen: false).loadPdfPaths();
  }

  @override
  Widget build(BuildContext context) {
    final pdfProvider = Provider.of<PdfScanner>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('PDF List'),

      ),
      body:RefreshIndicator (
          onRefresh: ()async{
            await pdfProvider.refreshPdfFiles('/storage/emulated/0/');
          },
        child: pdfProvider.isLoading
            ? Center(child: CircularProgressIndicator()) // ⏳ लोडिंग दिखाएगा
            : pdfProvider.pdfPaths.isEmpty
            ? Center(child: Text('No PDFs found'))
            : ListView.builder(
          itemCount: pdfProvider.pdfPaths.length,
          itemBuilder: (context, index) {
            return ListTile(
               leading: Icon(Icons.picture_as_pdf,color: Colors.red,),
              title: Text(pdfProvider.pdfPaths[index].split('/').last),

            );
          },
        ),
      ),
    );
  }
}
