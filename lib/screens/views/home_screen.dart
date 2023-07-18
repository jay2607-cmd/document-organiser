import 'dart:async';
import 'dart:io';

import 'package:document_organiser/screens/document_picker.dart';
import 'package:document_organiser/screens/views/pdf_preview.dart';
import 'package:document_organiser/screens/views/categories.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_thumbnail/pdf_thumbnail.dart';

import '../../boxes/boxes.dart';
import '../../settings/security.dart';
import 'image_preview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<File> imageFiles = [];
  List<File> pdfFiles = [];
  int base = -1;
  int check = -2;

  var identifier = new Map();

  List<String> labels = ['Images', 'PDFs'];

  late File file;

  @override
  void initState() {
    setState(() {
      loadImages();
      loadPDF();
    });
    print("initState");
    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  Future<void> loadImages() async {
    base = 0;
    // final directory = await getApplicationDocumentsDirectory();
    final directory = await getExternalStorageDirectory();
    print(directory);
    final files = directory?.listSync(recursive: true);
    final pngFiles = files?.whereType<File>().where((file) {
      String filename = file.path.toLowerCase().split('files/').last;
      print("New Data List ==>> ${filename.split("/")[0]}");
      if (identifier.containsKey(filename.split("/")[0])) {
        identifier[filename.split("/")[0]] =
            (identifier[filename.split("/")[0]]) + 1;
      } else {
        identifier[filename.split("/")[0]] = 1;
      }
      final extension = file.path.toLowerCase().split('.').last;
      return extension == 'png';
    }).toList();
    setState(() {
      check = 0;
      imageFiles = pngFiles!;
    });
  }

  Future<void> loadPDF() async {
    base = 0;
    // final directory = await getApplicationDocumentsDirectory();
    final directory = await getExternalStorageDirectory();
    print(directory);
    final files = directory?.listSync(recursive: true);
    final PDFFiles = files?.whereType<File>().where((file) {
      String filename = file.path.toLowerCase().split('files/').last;
      print("New Data List ==>> ${filename.split("/")[0]}");
      if (identifier.containsKey(filename.split("/")[0])) {
        identifier[filename.split("/")[0]] =
            (identifier[filename.split("/")[0]]) + 1;
      } else {
        identifier[filename.split("/")[0]] = 1;
      }
      final extension = file.path.toLowerCase().split('.').last;
      return extension == 'pdf';
    }).toList();
    setState(() {
      check = 0;
      pdfFiles = PDFFiles!;
    });
  }

  @override
  Widget build(BuildContext context) {
    var box = Boxes.getData();
    // print("identifier size-->> ${identifier.length}");
    return WillPopScope(
      onWillPop: () => showExitPopup(context),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text("MyDocs"),
            bottom: TabBar(
              tabs: [
                Tab(
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: "Categories",
                      ),
                      TextSpan(
                          text: " (${box.length})",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                  ),
                ),
                Tab(
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: "All Images",
                      ),
                      TextSpan(
                          text: " (${imageFiles.length})",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                  ),
                ),
                Tab(
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: "All PDFs",
                      ),
                      TextSpan(
                          text: " (${pdfFiles.length})",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                  ),
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
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert),
                onSelected: (value) {
                  // Handle menu item selection
                  if (value == 'security') {
                    // Perform action for menu item 1

                    // push to the account class
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Security()));
                  } else if (value == 'menu_item2') {
                    // Perform action for menu item 2
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'security',
                    child: Text('Security'),
                  ),
                  PopupMenuItem(
                    value: 'menu_item2',
                    child: Text('Menu Item 2'),
                  ),
                ],
              )

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
                child: Categories.withLength(
                    imageFiles.length + pdfFiles.length, identifier),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
                child: allImages(),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
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
                          builder: (context) => PdfPreview.forDelete(
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
                                    border:
                                        Border.all(color: Colors.transparent)),
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
        ? Center(child: Text("No Images Chosen"))
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

  Future<bool> showExitPopup(context) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              height: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Do you want to exit?"),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            print('yes selected');
                            exit(0);
                          },
                          child: Text("Yes"),
                          style: ElevatedButton.styleFrom(primary: Colors.red),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                          child: ElevatedButton(
                        onPressed: () {
                          print('no selected');
                          Navigator.of(context).pop();
                        },
                        child:
                            Text("No", style: TextStyle(color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                        ),
                      ))
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }
}

class CategoriesLength extends CategoriesState {
  CategoriesState categoriesState = CategoriesState();

  int dataLength() {
    return categoriesState.data;
  }
}
