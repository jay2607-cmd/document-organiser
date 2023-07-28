// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:document_organiser/screens/views/bookmark_screen.dart';
import 'package:document_organiser/screens/views/category_insider.dart';
import 'package:document_organiser/screens/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';

import '../../database/bookmark.dart';
import '../../provider/db_provider.dart';
import '../../utils/constants.dart';

class ImagePreview extends StatefulWidget {
  List<File> imageFiles = [];
  int index = 0;
  String filePath = "";
  File? file;
  String fromWhere = "";
  String categoryName = "";

  ImagePreview(
      {super.key,
      required this.filePath,
      required this.file,
      required this.imageFiles,
      required this.index,
      required this.fromWhere});

  ImagePreview.withCategoryName(
      {super.key,
      required this.filePath,
      required this.file,
      required this.imageFiles,
      required this.index,
      required this.fromWhere,
      required this.categoryName});

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  late TextEditingController editingController;
  bool isNotesSharingEnabled = false;

  bool isRemoved = false;

  TextEditingController renameController = TextEditingController();

  Box<Bookmark> bookmarkBox = Hive.box<Bookmark>('bookmark');
  late bool isBookmarked;
  @override
  void initState() {
    super.initState();
    openBox();
    DbProvider().getSharingNotesState().then((value) {
      setState(() {
        isNotesSharingEnabled = value;
      });
    });
    isBookmarked =
        bookmarkBox.values.any((bookmark) => bookmark.path == widget.filePath);

    print("widget.filePath ${widget.filePath}");
  }

  var notesBox;
  openBox() async {
    notesBox = await Hive.openBox("Notes");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
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
                "Image Preview",
                style: kAppbarStyle,
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: PhotoView(
                  backgroundDecoration:
                      const BoxDecoration(color: Colors.white),
                  imageProvider: FileImage(File(widget.filePath)),
                ),
              ),
              Text(widget.file!.path.substring(70)),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        child: IconButton(
                          color: Colors.blue,
                          onPressed: () async {
                            Share.shareFiles(
                              [widget.filePath],
                              text: isNotesSharingEnabled
                                  ? "${widget.filePath.substring(70)} \n"
                                      "Note : ${await notesBox.get(widget.filePath)}"
                                  : "${widget.filePath.substring(70)}",
                            );
                          },
                          icon: Image.asset(
                            'assets/images/share.png',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: Container(
                        height: 50,
                        child: IconButton(
                          color: Color(0xffFF5959),
                          onPressed: () {
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
                                          deleteFile(
                                              widget.filePath, widget.index);
                                          isRemoved = true;
                                          Navigator.pop(context);
                                          setState(() {});

                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: Image.asset(
                            'assets/images/delete.png',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: Container(
                        height: 50,
                        child: IconButton(
                          onPressed: () async {
                            setState(() {});
                            // show the info for the image
                            print(
                                "widget.filePath ${widget.filePath.toString()}");

                            if (await notesBox.get(widget.filePath) != null) {
                              String data = await notesBox.get(widget.filePath);

                              _openBottomDialog(context, data, widget.filePath);
                            } else {
                              String data = "";
                              _openBottomDialog(context, data, widget.filePath);
                            }
                          },
                          icon: Image.asset(
                            'assets/images/info1.png',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: renameIcon(context, widget.file, widget.index),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  IconButton renameIcon(BuildContext context, File? file, int position) {
    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title:
                  const Text('Rename!', style: TextStyle(color: Colors.blue)),
              content: const Text('Do you really want to rename this file!'),
              actions: [
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(10)),
                    hintText: 'Enter New Name',
                    helperText: 'Keep it meaningful',
                    labelText: 'Rename',
                    prefixIcon: const Icon(
                      Icons.drive_file_rename_outline_rounded,
                      color: Colors.blue,
                    ),
                  ),
                  controller: renameController,
                ),
                TextButton(
                  child: Text('Rename'),
                  onPressed: () async {
                    await changeFileNameOnly(
                        file!, "${renameController.text}.png");
                    // records.clear();
                    var path = file.path;
                    var lastSeparator =
                        path.lastIndexOf(Platform.pathSeparator);
                    var newPath =
                        "${path.substring(0, lastSeparator + 1)}${renameController.text}.png";
                    widget.filePath = newPath;

                    // check the bookmark feature

                    print("isBookmarked $isBookmarked");

                    if (isBookmarked) {
                      bookmarkBox.deleteAt(bookmarkBox.values
                          .toList()
                          .indexWhere(
                              (bookmark) => bookmark.path == file.path));

                      bookmarkBox.add(Bookmark(path: newPath));
                      print("bookmark added ${renameController.text}");
                    }

                    Navigator.pop(context);
                    setState(() {});
                  },
                ),
              ],
            );
          },
        );
      },
      icon: Image.asset(
        'assets/images/edit.png',
      ),
    );
  }

  Future<File?> changeFileNameOnly(File file, String newFileName) async {
    var path = file.path;
    var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    var newPath = path.substring(0, lastSeparator + 1) + newFileName;

    // Check if the new file name already exists
    var newFile = File(newPath);
    if (await newFile.exists()) {
      // Show an alert dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('File Name Already Exists'),
            content: const Text('The specified file name already exists.'),
            actions: [
              // Cancel button
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
              ),
              // Replace button
              TextButton(
                child: const Text('Replace'),
                onPressed: () {
                  replaceFile(file, "${renameController.text}.png");
                  _willPopCallback();
                  Navigator.pop(context);

                  setState(() {});
                },
              ),
            ],
          );
        },
      );
      return null; // Return null to indicate failure
    }

    // Rename the file
    await file.rename(newPath);
    return newFile;
  }

  Future<File> replaceFile(File file, String newFileName) async {
    var path = file.path;

    var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    var newPath = path.substring(0, lastSeparator + 1) + newFileName;
    print("new path: ${newPath}");
    return await file.rename(newPath);
  }

  void _openBottomDialog(BuildContext context, String data, String filePath) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                // mainAxisSize: MainAxisSize.min,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        // put your code for editing
                        onPressed: () async {
                          editingController = TextEditingController(
                              text: notesBox.get(widget.filePath));

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return SingleChildScrollView(
                                child: AlertDialog(
                                  title: const Text('Edit!',
                                      style: TextStyle(color: Colors.red)),
                                  content: Container(
                                      width: 300,
                                      child: const Text('Edit this notes')),
                                  actions: [
                                    TextField(
                                      maxLines: null,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.blue),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        hintText: 'Notes',
                                        // helperText: 'Keep it meaningful for future purposes',
                                        labelText: ' Notes (Optional)',
                                      ),
                                      controller: editingController,
                                    ),
                                    TextButton(
                                      child: Text('OK'),
                                      onPressed: () async {
                                        print(
                                            "editingController.text ${editingController.text}");

                                        // update new data into database
                                        await notesBox.put(widget.filePath,
                                            editingController.text);

                                        // retrieve that saved data
                                        data =
                                            await notesBox.get(widget.filePath);

                                        print("Edited Data $data");

                                        setState(() {});
                                        editingController.clear();
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );

                          setState(() {});
                        },
                        icon: Icon(Icons.edit),
                      )),
                  data.isNotEmpty
                      ? Text(
                          data,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Text("Empty Notes"),

                  // Add more Text widgets or any other content you need
                  // You can also use other widgets like ListView or SingleChildScrollView here
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> deleteFile(String filePath, int index) async {
    try {
      File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        setState(() {
          widget.imageFiles.remove(file);
          widget.imageFiles
              .removeAt(index); // Remove the deleted file from the list
        });

        _willPopCallback();
        print('$filePath deleted successfully');
      }
    } catch (e) {
      print('Error while deleting file: $e');
      _willPopCallback();
    }
  }

  Future<bool> _willPopCallback() {
    if (widget.fromWhere == "home") {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else if (widget.fromWhere == "categoryInsider") {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => CategoryInsider(
                  categoryLabel: widget.categoryName,
                  isFromCategories: false)));
    } else if (widget.fromWhere == "bookmark") {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => BookmarkScreen()));
    }
    return Future.value(true);
  }
}
