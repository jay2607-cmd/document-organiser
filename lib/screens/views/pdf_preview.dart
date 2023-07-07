import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'home_screen.dart';

class PdfPreview extends StatefulWidget {
   late String PdfPath;
   late List PdfList;
   late int index;
  PdfPreview.forDelete({super.key, required this.PdfPath,required this.PdfList, required this.index});

  // PdfPreview.forShare({super.key, required this.PdfPath});

  @override
  State<PdfPreview> createState() => _PdfPreviewState();
}

class _PdfPreviewState extends State<PdfPreview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PDF Preview"),
        actions: [
          IconButton(
            onPressed: () async {
              Share.shareFiles([widget.PdfPath],
                  text: widget.PdfPath.substring(67, 86));
            },
            icon: Icon(Icons.share),
          ),
          IconButton(
            onPressed: () async {

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Warning!',
                          style: TextStyle(color: Colors.red)),
                      content: const Text(
                          'Are you really want to delete this file!'),
                      actions: [
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            setState(() {
                              deleteFile(
                                  widget.PdfPath, widget.index);
                              Navigator.pop(context);
                              setState(() {});
                            });
                          },
                        ),
                      ],
                    );
                  },
                );
              },


            icon: Icon(Icons.delete),
          ),
        ],
      ),
      body: SfPdfViewer.file(File(widget.PdfPath)),
    );
  }

  Future<void> deleteFile(String filePath, int index) async {
    try {
      File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        setState(() {
          widget.PdfList.remove(file);
          widget.PdfList
              .removeAt(index); // Remove the deleted file from the list
        });
        // widget.imageFiles.removeAt(index);

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
        print('$filePath deleted successfully');
      }
    } catch (e) {
      // print('Error while deleting file: $e');
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    }
  }


}
