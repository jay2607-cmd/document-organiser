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

import '../../boxes/boxes.dart';
import '../../database/bookmark.dart';
import '../../provider/db_provider.dart';
import '../../utils/constants.dart';
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

  bool isHideCreationDate = false;

  TextEditingController searchController = TextEditingController();
  String search = "";

  Box<Bookmark> bookmarkBox = Hive.box<Bookmark>('bookmark');

  String fromWhere = "home";

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
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                  color: Colors.black,
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DocumentPicker(
                                  "Invoice",
                                  isFromCategories: false,
                                )));
                  },
                  icon: Image.asset(
                    "assets/images/add.png",
                    width: 25,
                    height: 25,
                  )),
              Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: IconButton(
                    color: Colors.black,
                    onPressed: () async {
                      if (isGridView!.getBool('isGrid') == true) {
                        await isGridView!.setBool('isGrid', false);
                      } else {
                        await isGridView!.setBool('isGrid', true);
                      }
                      setState(() {});
                    },
                    icon: isGridView!.getBool('isGrid') == true
                        ? Image.asset(
                            "assets/images/gridview.png",
                            width: 28,
                            height: 28,
                          )
                        : Image.asset(
                            "assets/images/listview.png",
                            width: 28,
                            height: 28,
                          )),
              ),
            ],
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
                  Navigator.pop(context);
                },
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                "My Docs",
                style: kAppbarStyle,
              ),
            ),
          ),
          body: TabBarView(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16, top: 16),
                child: Categories(
                  isFromCategories: false,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
                child: allImages(),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
                child: allPDFs(),
              ),
            ],
          ),
          bottomNavigationBar: Material(
            color: Color(0xff4F6DDC),
            child: Padding(
              padding: EdgeInsets.only(
                  left: 23,
                  right: 23), // Add 15px padding on both left and right sides
              child: TabBar(
                indicatorPadding: EdgeInsets.only(bottom: 18),
                indicatorColor: Colors.white,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 2, // Set the thickness of the indicator line
                // isScrollable: true,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                tabs: [
                  Tab(
                    height: 120,
                    icon: Image.asset(
                      "assets/images/allcategory.png",
                      height: 40,
                      width: 40,
                    ),
                    child: Text(
                      "Category (${box.length})",
                      style: kTabBarTextStyle,
                    ),
                  ),
                  Tab(
                    height: 120,
                    icon: Image.asset(
                      "assets/images/allimages.png",
                      height: 40,
                      width: 40,
                    ),
                    child: Text(
                      "All Images (${imageFiles.length})",
                      style: kTabBarTextStyle,
                    ),
                  ),
                  Tab(
                    height: 120,
                    icon: Image.asset(
                      "assets/images/pdffile.png",
                      height: 40,
                      width: 40,
                    ),
                    child: Text(
                      "All PDF's (${pdfFiles.length})",
                      style: kTabBarTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
/*
  BottomNavigationBar(
  backgroundColor: Color(0xff4F6DDC),
  type: BottomNavigationBarType
      .fixed, // Fix the type to show all buttons
  // currentIndex: _selectedIndex,
  // onTap: _onItemTapped,
  items: [
  BottomNavigationBarItem(
  icon: Image.asset("assets/images/allcategory.png",),
  label: 'Categories',
  ),
  BottomNavigationBarItem(
  icon: Image.asset("assets/images/allimages.png"),
  label: 'All Images',
  ),
  BottomNavigationBarItem(
  icon: Image.asset("assets/images/pdffile.png",),
  label: 'All PDfs',
  ),
  ],
  ),*/

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
        : isGridView!.getBool('isGrid') == true
            ? GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.58,
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
                            fromWhere: "home",
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Card(
                        child: Container(
                          color: Color(0xffF0F1F5),
                          child: Column(
                            children: [
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
                              Center(
                                child: Container(
                                  height: 200,
                                  // width: 200,
                                  child: PdfThumbnail.fromFile(
                                    file.path,
                                    currentPage: 1,
                                    height: 200,
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
                                            fromWhere: "home",
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20.0),
                                    child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Text(
                                          file.path.substring(70),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.5),
                                        )),
                                  ),
                                  /* Add the last modified date here if needed */
                                ],
                              ),
                            ],
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 7),
                    child: TextFormField(

                      controller: searchController,
                      decoration: InputDecoration(
                          fillColor: Color(0xffF0F1F5),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 17),
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
                            !position.toLowerCase().contains(
                                searchController.text.toLowerCase())) {
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
                                            child:
                                                Text(file.path.substring(70))),
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
        ? Center(child: Text("No Images Chosen"))
        : ValueListenableBuilder(
            valueListenable: Hive.box("favorites").listenable(),
            builder: (BuildContext context, Box<dynamic> box, Widget? child) {
              return isGridView!.getBool('isGrid') == true
                  ? GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.615,
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
                                  fromWhere: fromWhere,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4.0, vertical: 4),
                            child: Card(
                              child: Container(
                                color: Color(0xffF0F1F5),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: IconButton(
                                          onPressed: () {
                                            if (isBookmarked) {
                                              bookmarkBox.deleteAt(bookmarkBox
                                                  .values
                                                  .toList()
                                                  .indexWhere((bookmark) =>
                                                      bookmark.path ==
                                                      file.path));
                                            } else {
                                              bookmarkBox.add(
                                                  Bookmark(path: file.path));
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
                                      Container(
                                        height: 200,
                                        width: 150,
                                        child: Image.file(file),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Text(
                                              file.path.substring(70),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12.5),
                                            ),
                                          ),
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
                                filled: true,
                                fillColor: Color(0xffF0F1F5),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 17),
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
                              bool isBookmarked = bookmarkBox.values.any(
                                  (bookmark) => bookmark.path == file.path);

                              if (searchController.text.isNotEmpty &&
                                  !position.toLowerCase().contains(
                                      searchController.text.toLowerCase())) {
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
                                        fromWhere: fromWhere,
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
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 12.0, left: 6),
                                                  child: Align(
                                                    alignment: Alignment.center,
                                                    child:
                                                        SingleChildScrollView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      child: Text(
                                                        file.path.substring(70),
                                                      ),
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
                                          ),
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 16.0),
                                              child: IconButton(
                                                onPressed: () {
                                                  if (isBookmarked) {
                                                    bookmarkBox.deleteAt(
                                                        bookmarkBox
                                                            .values
                                                            .toList()
                                                            .indexWhere(
                                                                (bookmark) =>
                                                                    bookmark
                                                                        .path ==
                                                                    file.path));
                                                  } else {
                                                    bookmarkBox.add(Bookmark(
                                                        path: file.path));
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
