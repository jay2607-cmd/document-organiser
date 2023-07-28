import 'dart:io';

import 'package:document_organiser/screens/document_picker.dart';
import 'package:document_organiser/screens/views/pdf_preview.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_thumbnail/pdf_thumbnail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../database/bookmark.dart';
import '../../provider/db_provider.dart';
import '../../utils/constants.dart';
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

  bool isHideCreationDate = false;

  @override
  void initState() {
    super.initState();
    DbProvider().getHideCreationDateStatus().then((value) {
      isHideCreationDate = value;
      setState(() {});
      print("isHideCreationDate $isHideCreationDate");
    });
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
  void sortFilesByLastModified(List<File> files, String document) {
    files.sort((a, b) {
      var aModified = a.lastModifiedSync();
      var bModified = b.lastModifiedSync();
      return bModified.compareTo(aModified);
    });


  }

  @override
  Widget build(BuildContext context) {
    sortFilesByLastModified(imageFiles, "images");
    sortFilesByLastModified(pdfFiles, "pdfs");
    return DefaultTabController(
      length: 2,
      child: WillPopScope(
        onWillPop: _willPopCallback,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              unselectedLabelColor: Colors.black,
              indicator: MyTabIndicator(overlayColor: Color(0xff4F6DDC)),
              padding: EdgeInsets.symmetric(
                horizontal: 17.5,
              ),
              tabs: [
                Tab(
                  height: 50,
                  child: Text(
                    "${widget.categoryLabel} Images (${imageFiles.length})",
                    style: kUpperTabBarTextStyle,
                  ),
                ),
                Tab(
                  height: 50,
                  child: Text(
                    "${widget.categoryLabel} PDF's (${pdfFiles.length})",
                    style: kUpperTabBarTextStyle,
                  ),
                ),
              ],
            ),
            /*TabBar(
              tabs: [
                Tab(
                  child: Text(
                    "${widget.categoryLabel} Images (${imageFiles.length})",
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
            )*/
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: IconButton(
                icon: Image.asset(
                  'assets/images/back.png',
                  height: 24,
                  width: 24,
                ),
                onPressed: () {
                  _willPopCallback();
                },
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                "${widget.categoryLabel}",
                style: kAppbarStyle,
              ),
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
                  icon: Image.asset(
                    "assets/images/add.png",
                    width: 25,
                    height: 25,
                  )),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                    icon: Image.asset("assets/images/delete.png",
                        width: 25, height: 25),
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

                                  var outerBox =
                                      await Hive.openBox("OuterCount");
                                  // int count = outerBox  != null ? outerBox.get(widget.value) : isAdded = false;

                                  int count = outerBox == null
                                      ? 0
                                      : outerBox.get(widget.categoryLabel) ==
                                              null
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
              ),
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
        : Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 7),
                child: TextFormField(
                  controller: searchController,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xffF0F1F5),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 17),
                      hintText: "Search",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Image.asset(
                          "assets/images/search.png",
                          height: 10,
                          width: 10,
                        ),
                      )),
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
                  itemCount: pdfFiles.length,
                  itemBuilder: (BuildContext context, int index) {
                    File file = pdfFiles[index];
                    bool isBookmarked = bookmarkBox.values
                        .any((bookmark) => bookmark.path == file.path);
                    String position = file.path;

                    if (searchController.text.isNotEmpty &&
                        !position
                            .toLowerCase()
                            .contains(searchController.text.toLowerCase())) {
                      return SizedBox.shrink();
                    }

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
                              fromWhere: "home",
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        child: Card(
                          child: Container(
                            color: Color(0xffF0F1F5),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20.0),
                                    child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Text(file.path.substring(70))),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Container(
                                    height: 100,
                                    width: 100,
                                    child: PdfThumbnail.fromFile(
                                      file.path,
                                      currentPage: 1,
                                      height: 100,
                                      currentPageDecoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.transparent),
                                      ),
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
                                              fromWhere: "home",
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
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
                                        ? Image.asset(
                                            "assets/images/bo_mark.png",
                                            height: 20,
                                            width: 20,
                                          )
                                        : Image.asset(
                                            "assets/images/bo_mark_.png",
                                            height: 20,
                                            width: 20,
                                          ),
                                  ),
                                ),
                              ],
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
                      filled: true,
                      fillColor: Color(0xffF0F1F5), //<-- SEE
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 17),
                      hintText: "Search",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Image.asset(
                          "assets/images/search.png",
                          height: 10,
                          width: 10,
                        ),
                      )),
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
                            builder: (context) => ImagePreview(
                              filePath: imageFiles[index].path,
                              file: imageFiles[index],
                              imageFiles: imageFiles,
                              index: index,
                              fromWhere: "categoryInsider",
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        child: Card(
                          color: Color(0xffF0F1F5),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    height: 70,
                                    width: 80,
                                    child: Image.file(file),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 12.0, left: 6),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Text(
                                              file.path.substring(70),
                                            ),
                                          ),
                                        ),
                                      ),
                                      isHideCreationDate
                                          ? Text("")
                                          : FutureBuilder<DateTime>(
                                              future: getFileLastModified(
                                                  file.path),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<DateTime>
                                                      snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  // While waiting for the result, show a progress indicator
                                                  return CircularProgressIndicator();
                                                } else if (snapshot.hasError) {
                                                  // If an error occurred during the Future execution
                                                  return Text(
                                                      'Error: ${snapshot.error}');
                                                } else {
                                                  // If the Future completed successfully, show the last modified date
                                                  DateTime lastModified =
                                                      snapshot.data!;
                                                  return Text(
                                                      "${lastModified.toString().substring(0, lastModified.toString().length - 4)}");
                                                }
                                              },
                                            ),
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 16.0),
                                    child: IconButton(
                                      onPressed: () {
                                        if (isBookmarked) {
                                          bookmarkBox.deleteAt(bookmarkBox
                                              .values
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
                                          ? Image.asset(
                                              "assets/images/bo_mark.png",
                                              height: 20,
                                              width: 20,
                                            )
                                          : Image.asset(
                                              "assets/images/bo_mark_.png",
                                              height: 20,
                                              width: 20,
                                            ),
                                    ),
                                  ),
                                ),
                              ],
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

  Future<DateTime> getFileLastModified(String filepath) async {
    File file = File(filepath);

    if (await file.exists()) {
      DateTime lastModified = await file.lastModified();
      print("lastModified ${lastModified}");
      return lastModified;
    } else {
      throw Exception('File does not exist.');
    }
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

class MyTabIndicator extends Decoration {
  final Color overlayColor;

  const MyTabIndicator({required this.overlayColor});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _MyTabIndicatorPainter(overlayColor: overlayColor);
  }
}

class _MyTabIndicatorPainter extends BoxPainter {
  final Color overlayColor;

  _MyTabIndicatorPainter({required this.overlayColor});

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect rect = offset & configuration.size!;
    final Paint paint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(35)),
      paint,
    );
  }
}
