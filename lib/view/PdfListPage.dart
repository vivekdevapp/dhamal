import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:provider/provider.dart';

import '../controller/Getpdf.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  void initState() {
    super.initState();

    // Fetch PDF files after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GetPdf>(context, listen: false).fetchPdfFiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF List')),
      body: Consumer<GetPdf>(
        builder: (context, provider, child) {
          if (provider!.isloading) {
            return const Center(child: CircularProgressIndicator()); // Show loader
          }

          if (provider!.pdffiles.isEmpty) {
            return Center(child: ElevatedButton(onPressed: () async {
              await   Permission.storage.isGranted;

            }, child: const Text('get permission')));
          }

          return ListView.builder(
            itemCount: provider.pdffiles.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text(provider.pdffiles[index].path.split('/').last),
                subtitle: Text(provider!.pdffiles[index].path),
                onTap: () {

                },
              );
            },
          );
        },
      ),
    );
  }
}
