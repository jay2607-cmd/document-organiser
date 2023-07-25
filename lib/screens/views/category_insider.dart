import 'dart:io';

import 'package:document_organiser/screens/document_picker.dart';
import 'package:document_organiser/screens/views/pdf_preview.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_thumbnail/pdf_thumbnail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../database/bookmark.dart';
import 'home_screen.dart';
import 'image_preview.dart';

class CategoryInsider extends StatefulWidget {
  final String categoryLabel;
  final bool isFromCategories;

  const CategoryInsider(
      {super.key, required this.categoryLabel, required this.isFromCategories});

  @override
  State<CategoryInsider> createState() => CategoryInsiderState();
}

class CategoryInsiderState extends State<CategoryInsider> {
  List<File> imageFiles = [];
  List<File> pdfFiles = [];

  TextEditingController searchController = TextEditingController();
  String search = "";

  Box<Bookmark> bookmarkBox = Hive.box<Bookmark>('bookmark');

  bool isAllFilesRemoved = false;

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

    SharedPreferences imageLengthPref = await SharedPreferences.getInstance();

    imageLengthPref.setInt(
        widget.categoryLabel, (imageFiles.length + pdfFiles.length));
    print(
        "Added value in database : ${widget.categoryLabel} ::::: ${imageLengthPref.getInt(widget.categoryLabel)}");

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

    var outerCountBox = await Hive.openBox("OuterCount");
    int count = (imageFiles.length + pdfFiles.length);
    await outerCountBox.put(widget.categoryLabel, count);
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
                    if (widget.isFromCategories) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DocumentPicker(
                                    widget.categoryLabel,
                                    isFromCategories: true,
                                  )));
                    } else {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DocumentPicker(
                                    widget.categoryLabel,
                                    isFromCategories: true,
                                  )));
                    }
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
                              onPressed: () async {
                                deleteAllFilesInFolder();
                                isAllFilesRemoved = true;

                                var outerBox = await Hive.openBox("OuterCount");
                                // int count = outerBox  != null ? outerBox.get(widget.value) : isAdded = false;

                                int count = outerBox == null
                                    ? 0
                                    : outerBox.get(widget.categoryLabel) == null
                                        ? 0
                                        : outerBox.get(widget.categoryLabel);

                                if (isAllFilesRemoved) {
                                  outerBox.put(widget.categoryLabel, 0);
                                }
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

  Widget allPDFs() {
    return pdfFiles.isEmpty
        ? Center(child: Text("No ${widget.categoryLabel} Pdf file Chosen"))
        : ListView.builder(
            itemCount: pdfFiles.length,
            itemBuilder: (BuildContext context, int index) {
              File file = pdfFiles[index];
              bool isBookmarked = bookmarkBox.values
                  .any((bookmark) => bookmark.path == file.path);
              return GestureDetector(
                onTap: () {
                  print("${index}");
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PdfPreview.withCategory(
                        PdfPath: pdfFiles[index].path,
                        index: index,
                        PdfList: pdfFiles,
                        fromWhere: "categoryInsider", category: widget.categoryLabel,
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
                                border: Border.all(color: Colors.transparent)),
                            backgroundColor: Colors.transparent,
                            onPageClicked: (page) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PdfPreview.forDelete(
                                    PdfPath: pdfFiles[index].path,
                                    index: index,
                                    PdfList: pdfFiles,
                                    fromWhere: "categoryInsider",
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
                            onPressed: () {
                              if (isBookmarked) {
                                bookmarkBox.deleteAt(bookmarkBox.values
                                    .toList()
                                    .indexWhere((bookmark) =>
                                        bookmark.path == file.path));
                              } else {
                                bookmarkBox.add(Bookmark(path: file.path));
                              }
                              setState(
                                  () {}); // Update the UI by calling setState
                            },
                            icon: isBookmarked
                                ? Icon(
                                    Icons.bookmark,
                                    color: Colors.red,
                                  )
                                : Icon(
                                    Icons.bookmark_border,
                                    color: Colors.red,
                                  ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
  }

  allImages() {
    return imageFiles.isEmpty
        ? Center(child: Text("No ${widget.categoryLabel} Images Chosen"))
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Search",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String? value) {
                    print(value);
                    setState(() {
                      search = value.toString();
                    });
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: imageFiles.length,
                  itemBuilder: (BuildContext context, int index) {
                    File file = imageFiles[index];
                    String position = file.path;
                    bool isBookmarked = bookmarkBox.values
                        .any((bookmark) => bookmark.path == file.path);

                    if (searchController.text.isNotEmpty &&
                        !position
                            .toLowerCase()
                            .contains(searchController.text.toLowerCase())) {
                      return SizedBox.shrink();
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImagePreview.withCategoryName(
                              filePath: imageFiles[index].path,
                              file: imageFiles[index],
                              imageFiles: imageFiles,
                              index: index,
                              fromWhere: "categoryInsider",
                              categoryName: widget.categoryLabel,
                            ),
                          ),
                        );
                      },

                      child: Container(
                        color: Colors.grey.shade200,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4.0, vertical: 1),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    height: 70,
                                    width: 80,
                                    child: Image.file(file),
                                  ),
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 12.0, left: 6),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            file.path.substring(70),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      if (isBookmarked) {
                                        bookmarkBox.deleteAt(bookmarkBox.values
                                            .toList()
                                            .indexWhere((bookmark) =>
                                                bookmark.path == file.path));
                                      } else {
                                        bookmarkBox
                                            .add(Bookmark(path: file.path));
                                      }
                                      setState(
                                          () {}); // Update the UI by calling setState
                                    },
                                    icon: isBookmarked
                                        ? Icon(
                                            Icons.bookmark,
                                            color: Colors.red,
                                          )
                                        : Icon(
                                            Icons.bookmark_border,
                                            color: Colors.red,
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
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
