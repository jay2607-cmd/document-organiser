import 'dart:io';

import 'package:document_organiser/screens/document_picker.dart';
import 'package:document_organiser/screens/views/pdf_preview.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_thumbnail/pdf_thumbnail.dart';

import 'home_screen.dart';
import 'image_preview.dart';

class CategoryInsider extends StatefulWidget {
  final String categoryLabel;
  const CategoryInsider({super.key, required this.categoryLabel});

  @override
  State<CategoryInsider> createState() => CategoryInsiderState();
}

class CategoryInsiderState extends State<CategoryInsider> {
   List<File> imageFiles = [];
   List<File> pdfFiles = [];

  late File file;

  late String filepath;

  @override
  void initState() {
    super.initState();
    setState(() {
      loadImages();
      loadPDF();
    });
  }

  Future<void> loadImages() async {
    final directory = await getExternalStorageDirectory();
    print(directory);
    String subfolderPath = '${directory?.path}/${widget.categoryLabel}';
    print("subfolderPath $subfolderPath ");

    final subfolder = Directory(subfolderPath);

    if (!subfolder.existsSync()) {
      // Handle the case when the subfolder does not exist
      return;
    }

    final files = subfolder.listSync(recursive: true);
    final pngFiles = files.whereType<File>().where((file) {
      final extension = file.path.toLowerCase().split('.').last;
      return extension == 'png';
    }).toList();
    setState(() {
      imageFiles = pngFiles;
    });
    print("s length : ${imageFiles.length}");
  }

  Future<void> loadPDF() async {
    final directory = await getExternalStorageDirectory();
    print(directory);

    final subfolderPath = '${directory?.path}/${widget.categoryLabel}';

    final subfolder = Directory(subfolderPath);

    var files;
    try {
      files = subfolder.listSync(recursive: true);
    } catch (e) {
      print(e);
    }
    final PDFFiles = files.whereType<File>().where((file) {
      final extension = file.path.toLowerCase().split('.').last;
      return extension == 'pdf';
    }).toList();

    setState(() {
      pdfFiles = PDFFiles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: WillPopScope(
        onWillPop: _willPopCallback,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: "${widget.categoryLabel} Images",
                      ),
                      TextSpan(
                          text: " (${imageFiles.length})",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                  ),
                  // text:  "${widget.categoryLabel} Images  (${imageFiles.length})",
                ),
                Tab(
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: "${widget.categoryLabel} PDF's",
                      ),
                      TextSpan(
                          text: " (${pdfFiles.length})",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                  ),
                ),
              ],
            ),
            title: Text(widget.categoryLabel),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                _willPopCallback();
              },
            ),
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                DocumentPicker(widget.categoryLabel)));
                  },
                  icon: Icon(Icons.add)),
              IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Warning!',
                              style: TextStyle(color: Colors.red)),
                          content: Text(
                              'Do you really want to delete all ${widget.categoryLabel} images and PDFs?'),
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
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
                child: allImages(),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
                child: allPDFs(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /*Widget allPDFs() {
    return pdfFiles.isEmpty
        ? Center(child: Text("No ${widget.categoryLabel} Pdf file Chosen"))
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
              return GestureDetector(
                onTap: () {
                  print("${index}");
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PdfPreview.forDelete(
                                PdfPath: pdfFiles[index].path,
                                index: index,
                                PdfList: pdfFiles,
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
                        child: PdfThumbnail.fromFile(
                          file.path,
                          scrollToCurrentPage: true,
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
                        )),
                    Text(file.path.substring(70, 81)),
                    Text(file.path.substring(81, 89)),

                    // Text(file.path),
                  ],
                ),
              );
            },
          );
  }*/

  /*Widget allImages() {
    return imageFiles.isEmpty
        ? Center(child: Text("No ${widget.categoryLabel} Images Chosen"))
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
                    Container(height: 250, width: 250, child: Image.file(imageFiles[index])),
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
  }*/

   Widget allPDFs() {
     return pdfFiles.isEmpty
         ? Center(child: Text("No ${widget.categoryLabel} Pdf file Chosen"))
         : ValueListenableBuilder(
         valueListenable: Hive.box("favorites").listenable(),
         builder: (BuildContext context, Box<dynamic> box, Widget? child) {
           return ListView.builder(
             /*gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5 / 3,
                  crossAxisSpacing: 20.0,
                  mainAxisSpacing: 30.0,
                ),*/
             itemCount: pdfFiles.length,
             itemBuilder: (BuildContext context, int index) {
               final isFavorites = box.get(index) != null;
               file = pdfFiles[index];
               return GestureDetector(
                 onTap: () {
                   print("${index}");
                   Navigator.pushReplacement(
                     context,
                     MaterialPageRoute(
                       builder: (context) =>
                           PdfPreview.forDelete(
                             PdfPath: pdfFiles[index].path,
                             index: index,
                             PdfList: pdfFiles,
                           ),
                     ),
                   );
                 },
                 child: Card(
                   child: Stack(
                     children: [
                       Container(
                           height: 120,
                           width: 80,
                           child: PdfThumbnail.fromFile(
                             file.path,
                             currentPage: 1,
                             height: 120,
                             currentPageDecoration: BoxDecoration(
                                 border: Border.all(
                                     color: Colors.transparent)),
                             backgroundColor: Colors.transparent,
                             onPageClicked: (page) {
                               Navigator.pushReplacement(
                                 context,
                                 MaterialPageRoute(
                                   builder: (context) =>
                                       PdfPreview.forDelete(
                                         PdfPath: pdfFiles[index].path,
                                         index: index,
                                         PdfList: pdfFiles,
                                       ),
                                 ),
                               );
                             },
                           )
                         // SfPdfViewer.file(
                         //   File(file.path),
                         // ),
                       ),
                       Padding(
                         padding: const EdgeInsets.only(top: 35.0),
                         child: Align(
                             alignment: Alignment.topCenter,
                             child: Text(file.path.substring(70))),
                       ),
                       Padding(
                         padding: const EdgeInsets.only(top: 25.0),
                         child: Align(
                           alignment: Alignment.topRight,
                           child: IconButton(
                               onPressed: () async {
                                 if (isFavorites) {
                                   await box.delete(index);
                                 } else {
                                   await box.put(index, file.path);
                                   const snackBar = SnackBar(
                                     content: Text(
                                       "Added successfully",
                                     ),
                                     duration: Duration(seconds: 1),
                                   );
                                   ScaffoldMessenger.of(context)
                                       .showSnackBar(snackBar);
                                 }
                               },
                               icon: isFavorites
                                   ? Icon(
                                 Icons.bookmark,
                                 color: Colors.red,
                               )
                                   : Icon(
                                 Icons.bookmark_border,
                                 color: Colors.red,
                               )),
                         ),
                       )
                     ],
                   ),
                 ),
               );
             },
           );
         });
   }

   allImages() {
     return imageFiles.isEmpty
         ? Center(child: Text("No ${widget.categoryLabel} Images Chosen"))
         : ValueListenableBuilder(
         valueListenable: Hive.box("favorites").listenable(),
         builder: (BuildContext context, Box<dynamic> box, Widget? child) {
           return ListView.builder(
             /*gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            childAspectRatio: 1.5 / 3,
            // crossAxisSpacing: 20.0,
            // mainAxisSpacing: 30.0,
          ),*/
             itemCount: imageFiles.length,
             itemBuilder: (BuildContext context, index) {
               final isFavorites = box.get(index) != null;
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
                 child: Container(
                   color: Colors.grey.shade200,
                   child: Padding(
                     padding: const EdgeInsets.symmetric(
                         horizontal: 4.0, vertical: 1),
                     child: Card(
                       child: Padding(
                         padding: const EdgeInsets.all(8.0),
                         child: Stack(
                           // crossAxisAlignment: CrossAxisAlignment.center,
                           // mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Align(
                               alignment: Alignment.centerLeft,
                               child: Container(
                                   height: 70,
                                   width: 80,
                                   child: Image.file(file)),
                             ),
                             // Text(file.path),
                             Padding(
                               padding:
                               const EdgeInsets.only(top: 12.0, left: 6),
                               child: Align(
                                 alignment: Alignment.center,
                                 child: SingleChildScrollView(
                                     scrollDirection: Axis.horizontal,
                                     child: Text(
                                       file.path.substring(70),
                                     )),
                               ),
                             ),

                             Align(
                               alignment: Alignment.topRight,
                               child: IconButton(
                                   onPressed: () async {
                                     if (isFavorites) {
                                       await box.delete(index);
                                     } else {
                                       await box.put(index, file.path);
                                       const snackBar = SnackBar(
                                         content: Text(
                                           "Added successfully",
                                         ),
                                         duration: Duration(seconds: 1),
                                       );
                                       ScaffoldMessenger.of(context)
                                           .showSnackBar(snackBar);
                                     }
                                   },
                                   icon: isFavorites
                                       ? Icon(
                                     Icons.bookmark,
                                     color: Colors.red,
                                   )
                                       : Icon(
                                     Icons.bookmark_border,
                                     color: Colors.red,
                                   )),
                             )

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
                       ),
                     ),
                   ),
                 ),
               );
             },
           );
         });
   }

  Future<bool> _willPopCallback() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomeScreen()));
    return Future.value(true);
  }

  Future<void> deleteAllFilesInFolder() async {
    String folderPath =
        "/storage/emulated/0/Android/data/com.example.document_organiser/files/${widget.categoryLabel}";
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
