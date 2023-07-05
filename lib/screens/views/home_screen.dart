import 'dart:io';

import 'package:document_organiser/screens/document_picker.dart';
import 'package:document_organiser/screens/views/pdf_preview.dart';
import 'package:document_organiser/screens/reusable_grid_view.dart';
import 'package:document_organiser/screens/views/categories.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
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
          bottom: TabBar(
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
                          builder: (context) => DocumentPicker.nothing()));
                },
                icon: const Icon(Icons.add)),
            IconButton(
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
                }),
          ],
        ),
        body: TabBarView(
          children: [
            const Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
              child: Categories(),
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

  GridView allPDFs() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5 / 3,
        crossAxisSpacing: 20.0,
        mainAxisSpacing: 30.0,
      ),
      itemCount: pdfFiles.length,
      itemBuilder: (BuildContext context, int index) {
        file = pdfFiles[index];
        return GestureDetector(
          onTap: () {
            print("${index}");
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PdfPreview(
                          PdfPath: pdfFiles[index].path,
                        )));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Container(height: 250,width: 250,child: Image.file(file)),
              // Text(file.path),

              // child: Image.file(file),
              Container(
                height: 260,
                width: 250,
                child: SfPdfViewer.file(
                  File(file.path),
                ),
              ),
              Text(file.path.substring(70, 81)),
              Text(file.path.substring(81, 89)),

              // Text(file.path),
            ],
          ),
        );
      },
    );
  }

  GridView allImages() {
    return GridView.builder(
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
              Text(file.path.substring(70, 81)),
              Text(file.path.substring(81, 89)),

              SizedBox(
                height: 30,
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

  Future<void> deleteAllFilesInFolder() async {
    String folderPath =
        "/storage/emulated/0/Android/data/com.example.document_organiser/files/";
    Directory folder = Directory(folderPath);
    if (await folder.exists()) {
      List<FileSystemEntity> entities = folder.listSync();
      for (FileSystemEntity entity in entities) {
        if (entity is File) {
          await entity.delete();
          print('Deleted file: ${entity.path}');
        }
      }
      setState(() {
        imageFiles.removeRange(
            0, imageFiles.length); // Clear the file list after deletion

        pdfFiles.removeRange(0, pdfFiles.length);
      });
      print('All files in folder deleted successfully');
    } else {
      print('Folder does not exist');
    }
  }
}
