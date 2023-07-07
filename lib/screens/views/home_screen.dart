import 'dart:io';

import 'package:document_organiser/screens/document_picker.dart';
import 'package:document_organiser/screens/views/pdf_preview.dart';
import 'package:document_organiser/screens/reusable_grid_view.dart';
import 'package:document_organiser/screens/views/categories.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_thumbnail/pdf_thumbnail.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'image_preview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<File> imageFiles = [];
  List<File> pdfFiles = [];


  List<String> labels = ['Images', 'PDFs'];

  late File file;

  @override
  void initState() {
    super.initState();
    setState(() {
      loadImages();
      loadPDF();
    });
    print("initState");
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> loadImages() async {
    // final directory = await getApplicationDocumentsDirectory();
    final directory = await getExternalStorageDirectory();
    print(directory);
    final files = directory?.listSync(recursive: true);
    final pngFiles = files?.whereType<File>().where((file) {
      final extension = file.path.toLowerCase().split('.').last;
      return extension == 'png';
    }).toList();
    setState(() {
      imageFiles = pngFiles!;
    });
  }

  Future<void> loadPDF() async {
    // final directory = await getApplicationDocumentsDirectory();
    final directory = await getExternalStorageDirectory();
    print(directory);
    final files = directory?.listSync(recursive: true);
    final PDFFiles = files?.whereType<File>().where((file) {
      final extension = file.path.toLowerCase().split('.').last;
      return extension == 'pdf';
    }).toList();
    setState(() {
      pdfFiles = PDFFiles!;
    });

  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text("MyDocs"),
          bottom: const TabBar(
            tabs: [
              Tab(
                text: "Categories",
              ),
              Tab(
                text: "All Images",
              ),
              Tab(
                text: "All PDFs",
              ),
            ],
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DocumentPicker("Invoice")));
                },
                icon: const Icon(Icons.add)),
            /*IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Warning!',
                            style: TextStyle(color: Colors.red)),
                        content: const Text(
                            'Do you really want to delete all images!'),
                        actions: [
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              deleteAllFilesInFolder();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                  setState(() {});
                }),*/
          ],
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
              child: Categories.withLength(imageFiles.length + pdfFiles.length),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: allImages(),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: allPDFs(),
            ),
          ],
        ),
      ),
    );
  }

  /*Widget allPDFs() {
    return pdfFiles.isEmpty
        ? Center(child: Text("No Pdf file Chosen"))
        : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5 / 3,
              crossAxisSpacing: 20.0,
              mainAxisSpacing: 30.0,
            ),
            itemCount: pdfFiles.length,
            itemBuilder: (BuildContext context, int index) {
              file = pdfFiles[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Container(height: 250,width: 250,child: Image.file(file)),
                  // Text(file.path),

                  // child: Image.file(file),
                  Container(
height: 260,
                      width: 250,
                      child: GestureDetector(
                          onTap: () {
                            print("${index}");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PdfPreview.forDelete(
                                  PdfPath: pdfFiles[index].path,
                                  index: index,
                                  PdfList: pdfFiles,
                                ),
                              ),
                            );
                          },
                          child: PdfThumbnail.fromFile(
                            file.path,
                            currentPage: 1,
                            height: 260,
                            backgroundColor: Colors.transparent,
                            onPageClicked: (page) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PdfPreview.forDelete(
                                    PdfPath: pdfFiles[index].path,
                                    index: index,
                                    PdfList: pdfFiles,
                                  ),
                                ),
                              );
                            },
                          ))
                      // SfPdfViewer.file(
                      //   File(file.path),
                      // ),
                      ),


                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(file.path.substring(70)),
                  ),

                  // Text(file.path),
                ],
              );
            },
          );
  }*/
  Widget allPDFs() {
    return pdfFiles.isEmpty
        ? Center(child: Text("No Pdf file Chosen"))
        : GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5 / 3,
        crossAxisSpacing: 20.0,
        mainAxisSpacing: 30.0,
      ),
      itemCount: pdfFiles.length,
      itemBuilder: (BuildContext context, int index) {
        file = pdfFiles[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Container(height: 250,width: 250,child: Image.file(file)),
            // Text(file.path),

            // child: Image.file(file),
            Container(
                height: 260,
                width: 250,
                child: GestureDetector(
                    onTap: () {
                      print("${index}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PdfPreview.forDelete(
                            PdfPath: pdfFiles[index].path,
                            index: index,
                            PdfList: pdfFiles,
                          ),
                        ),
                      );
                    },
                    child: PdfThumbnail.fromFile(
                      file.path,
                      currentPage: 1,
                      height: 260,
                      
                      backgroundColor: Colors.transparent,
                      onPageClicked: (page) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfPreview.forDelete(
                              PdfPath: pdfFiles[index].path,
                              index: index,
                              PdfList: pdfFiles,
                            ),
                          ),
                        );
                      },
                    ))
              // SfPdfViewer.file(
              //   File(file.path),
              // ),
            ),
            Text(file.path.substring(70))

            // Text(file.path),
          ],
        );
      },
    );
  }

  Widget allImages() {
    return imageFiles.isEmpty
        ? Center(child: Text("No Images Chosen"))
        : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5 / 3,
              crossAxisSpacing: 20.0,
              mainAxisSpacing: 30.0,
            ),
            itemCount: imageFiles.length,
            itemBuilder: (BuildContext context, int index) {

              file = imageFiles[index];

              return GestureDetector(
                onTap: () {
                  print("${index}");
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ImagePreview(
                                filePath: imageFiles[index].path,
                                file: imageFiles[index],
                                imageFiles: imageFiles,
                                index: index,
                              )));
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(height: 250, width: 250, child: Image.file(file)),
                    // Text(file.path),


                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(file.path.substring(70)),
                    ),


                    // child: Image.file(file),
                    // Container(
                    //   height: 260,
                    //   width: 250,
                    //   child: SfPdfViewer.file(
                    //     File(file.path),
                    //   ),
                    // ),

                    // Text(file.path),
                  ],
                ),
              );
            },
          );
  }

}
