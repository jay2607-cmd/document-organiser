import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfPreview extends StatefulWidget {
  final String PdfPath;
   PdfPreview({super.key, required this.PdfPath});

  @override
  State<PdfPreview> createState() => _PdfPreviewState();
}

class _PdfPreviewState extends State<PdfPreview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PDF Preview"),
      ),
      body: SfPdfViewer.file(File(widget.PdfPath)),
    );
  }
}
