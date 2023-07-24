import 'dart:async';
import 'dart:io';

import 'package:document_organiser/screens/document_picker.dart';
import 'package:document_organiser/screens/views/pdf_preview.dart';
import 'package:document_organiser/screens/views/categories.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_thumbnail/pdf_thumbnail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../boxes/bookmark_box.dart';
import '../../boxes/boxes.dart';
import '../../database/bookmark.dart';
import '../../provider/db_provider.dart';
import '../../settings/security.dart';
import '../../settings/settings_screen.dart';
import 'image_preview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<File> imageFiles = [];
  List<File> pdfFiles = [];

  bool isImageAdded = false;
  bool isPdfAdded = false;

  late File file;

  bool isHideCreationDate = false;

  TextEditingController searchController = TextEditingController();
  String search = "";

  var isFavorites = false;

  Box<Bookmark> bookmarkBox = Hive.box<Bookmark>('bookmark');

  @override
  void initState() {
    setState(() {
      loadImages();
      loadPDF();
      viewStatus();
    });
    print("initState");

    WidgetsBinding.instance.addObserver(this);
    super.initState();

    DbProvider().getHideCreationDateStatus().then((value) {
      isHideCreationDate = value;
      setState(() {});
      print("isHideCreationDate $isHideCreationDate");
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // print("didChangeAppLifecycleState");
    if (state == AppLifecycleState.resumed) {
      // user returned to our app
      print("resumed");
    } else if (state == AppLifecycleState.inactive) {
      // app is inactive
      print("inactive");
    } else if (state == AppLifecycleState.paused) {
      // user is about quit our app temporally
      print("paused");
    } else if (state == AppLifecycleState.detached) {
      print("suspending");
      // app suspended (not used in iOS)
    }
  }

  SharedPreferences? isGridView;
  viewStatus() async {
    isGridView = await SharedPreferences.getInstance();
    if (isGridView?.getBool("isGrid") == null) {
      await isGridView!.setBool('isGrid', false);
    }
    print(isGridView!.getBool('isGrid'));
  }

  Future<void> loadImages() async {
    // final directory = await getApplicationDocumentsDirectory();
    final directory = await getExternalStorageDirectory();
    print(directory);
    final files = directory?.listSync(recursive: true);
    final pngFiles = files?.whereType<File>().where((file) {
      String filename = file.path.toLowerCase().split('files/').last;
      print("New Data List ==>> ${filename.split("/")[0]}");

      final extension = file.path.toLowerCase().split('.').last;
      return extension == 'png';
    }).toList();
    setState(() {
      imageFiles = pngFiles!;
    });
  }

  void sortFilesByLastModified(List<File> files, String document) {
    files.sort((a, b) {
      var aModified = a.lastModifiedSync();
      var bModified = b.lastModifiedSync();
      return bModified.compareTo(aModified);
    });

    // print("oldImagefileLength ${imageLength}");
    print("NewImagefileLength ${imageFiles.length}");

    if (document == "images") {
      // shift index
      print("shift index");
    }

    if (document == "pdfs") {}
  }

  Future<void> loadPDF() async {
    // final directory = await getApplicationDocumentsDirectory();
    final directory = await getExternalStorageDirectory();
    print(directory);
    final files = directory?.listSync(recursive: true);
    final PDFFiles = files?.whereType<File>().where((file) {
      String filename = file.path.toLowerCase().split('files/').last;
      print("New Data List ==>> ${filename.split("/")[0]}");
      final extension = file.path.toLowerCase().split('.').last;
      return extension == 'pdf';
    }).toList();
    setState(() {
      pdfFiles = PDFFiles!;
    });
  }

  @override
  Widget build(BuildContext context) {
    sortFilesByLastModified(imageFiles, "images");
    sortFilesByLastModified(pdfFiles, "pdfs");
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
              IconButton(
                  onPressed: () async {
                    if (isGridView!.getBool('isGrid') == true) {
                      await isGridView!.setBool('isGrid', false);
                    } else {
                      await isGridView!.setBool('isGrid', true);
                    }
                    setState(() {});
                  },
                  icon: isGridView!.getBool('isGrid') == true
                      ? Icon(Icons.list)
                      : Icon(Icons.grid_view_sharp)),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert),
                onSelected: (value) {
                  // Handle menu item selection
                  if (value == 'security') {
                    // Perform action for menu item 1

                    // push to the account class
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Security()));
                  } else if (value == 'settings') {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SettingScreen()));
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'security',
                    child: Text('Security'),
                  ),
                  PopupMenuItem(
                    value: 'settings',
                    child: Text('Settings'),
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
                child:
                    Categories.withLength(imageFiles.length + pdfFiles.length),
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

  Widget allPDFs() {
    return pdfFiles.isEmpty
        ? Center(child: Text("No Pdf file Chosen"))
        : ValueListenableBuilder(
            valueListenable: Hive.box("favorites").listenable(),
            builder: (BuildContext context, Box<dynamic> box, Widget? child) {
              return isGridView!.getBool('isGrid') == true
                  ? GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.5 / 3,
                      ),
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
                                builder: (context) => PdfPreview.forDelete(
                                  PdfPath: pdfFiles[index].path,
                                  index: index,
                                  PdfList: pdfFiles,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            child: Column(
                              children: [
                                Container(
                                  height: 193,
                                  width: 200,
                                  child: PdfThumbnail.fromFile(
                                    file.path,
                                    currentPage: 1,
                                    height: 193,
                                    currentPageDecoration: BoxDecoration(
                                      border:
                                          Border.all(color: Colors.transparent),
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
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20.0),
                                      child: Text(file.path.substring(70)),
                                    ),
                                    /* Add the last modified date here if needed */
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
                        );
                      },
                    )
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
                                Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20.0),
                                    child: Text(file.path.substring(70)),
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
                                        border:
                                            Border.all(color: Colors.transparent),
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
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
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
              return isGridView!.getBool('isGrid') == true
                  ? GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.5 / 3,
                      ),
                      itemCount: imageFiles.length,
                      itemBuilder: (BuildContext context, index) {
                        File file = imageFiles[index];
                        bool isBookmarked = bookmarkBox.values
                            .any((bookmark) => bookmark.path == file.path);

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
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 200,
                                        width: 150,
                                        child: Image.file(file),
                                      ),
                                      Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 12.0, left: 6),
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child:
                                                  Text(file.path.substring(70)),
                                            ),
                                          ),
                                          // Add the last modified date here if needed
                                        ],
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          if (isBookmarked) {
                                            bookmarkBox.deleteAt(bookmarkBox
                                                .values
                                                .toList()
                                                .indexWhere((bookmark) =>
                                                    bookmark.path ==
                                                    file.path));
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
                    )
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
                              file = imageFiles[index];
                              String position = file.path;

                              if (searchController.text.isNotEmpty &&
                                  !position.toLowerCase().contains(
                                      searchController.text.toLowerCase())) {
                                return SizedBox.shrink();
                              }

                              final isFavorites = box.get(index) != null;

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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 12.0, left: 6),
                                                  child: Align(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      file.path.substring(70),
                                                    ),
                                                  ),
                                                ),
                                                isHideCreationDate
                                                    ? Text("")
                                                    : FutureBuilder<DateTime>(
                                                        future:
                                                            getFileLastModified(
                                                                file.path),
                                                        builder: (BuildContext
                                                                context,
                                                            AsyncSnapshot<
                                                                    DateTime>
                                                                snapshot) {
                                                          if (snapshot
                                                                  .connectionState ==
                                                              ConnectionState
                                                                  .waiting) {
                                                            // While waiting for the result, show a progress indicator
                                                            return CircularProgressIndicator();
                                                          } else if (snapshot
                                                              .hasError) {
                                                            // If an error occurred during the Future execution
                                                            return Text(
                                                                'Error: ${snapshot.error}');
                                                          } else {
                                                            // If the Future completed successfully, show the last modified date
                                                            DateTime
                                                                lastModified =
                                                                snapshot.data!;
                                                            return Text(
                                                                "${lastModified.toString().substring(0, lastModified.toString().length - 4)}");
                                                          }
                                                        },
                                                      ),
                                              ],
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                if (isFavorites) {
                                                  await box.delete(index);
                                                } else {
                                                  await box.put(
                                                      index, file.path);
                                                  const snackBar = SnackBar(
                                                    content: Text(
                                                      "Added successfully",
                                                    ),
                                                    duration:
                                                        Duration(seconds: 1),
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
