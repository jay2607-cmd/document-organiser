// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:document_organiser/screens/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';

import '../../provider/db_provider.dart';

class ImagePreview extends StatefulWidget {
  List<File> imageFiles = [];
  int index = 0;
  String filePath = "";
  File? file;
  String categoryLabel = "";

  ImagePreview({
    super.key,
    required this.filePath,
    required this.file,
    required this.imageFiles,
    required this.index,
  });



  ImagePreview.withCategoryName(
      {super.key,
      required this.filePath,
      required this.file,
      required this.imageFiles,
      required this.index,
      required this.categoryLabel});

  String updatedPath = "";
  ImagePreview.withInfo({super.key, required this.updatedPath});

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  late TextEditingController editingController;
  bool isNotesSharingEnabled = false;

  bool isRemoved = false;

  TextEditingController renameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    openBox();
    DbProvider().getSharingNotesState().then((value) {
      setState(() {
        isNotesSharingEnabled = value;
      });
    });
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
            leading: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  _willPopCallback();
                },
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                "Preview",
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
                          icon: Icon(Icons.share),
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
                                        setState(() async {
                                          deleteFile(
                                              widget.filePath, widget.index);
                                          isRemoved = true;

                                          var outerBox =
                                              await Hive.openBox("OuterCount");
                                          // int count = outerBox  != null ? outerBox.get(widget.value) : isAdded = false;

                                          int count = outerBox == null
                                              ? 0
                                              : outerBox.get(widget
                                                          .categoryLabel) ==
                                                      null
                                                  ? 0
                                                  : outerBox.get(
                                                      widget.categoryLabel);

                                          if (isRemoved) {
                                            outerBox.put(widget.categoryLabel,
                                                count - 1);
                                          }

                                          Navigator.pop(context);
                                          setState(() {});
                                        });
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(Icons.delete),
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
                          icon: Icon(Icons.info_outline),
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
                    Navigator.pop(context);

                    await changeFileNameOnly(
                        file!, "${renameController.text}.png");
                    // records.clear();
                    var path = file.path;
                    var lastSeparator =
                        path.lastIndexOf(Platform.pathSeparator);
                    var newPath =
                        "${path.substring(0, lastSeparator + 1)}${renameController.text}.png";
                    widget.filePath = newPath;
                    print(
                        "List Path ${widget.imageFiles.elementAt(position)}\nNewPath $newPath");

                    setState(() {});
                    /*getApplicationDocumentsDirectory().then((value) {
                        appDirectory = value;
                        appDirectory.list().listen((onData) {
                          if (onData.path.contains('.aac')) records.add(onData.path);
                        }).onDone(() {
                          records = records.reversed.toList();
                          setState(() {});
                        });
                      });*/
                  },
                ),
              ],
            );
          },
        );
      },

      icon: Icon(Icons.drive_file_rename_outline_rounded),
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
                  Navigator.of(context).pop(file);
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

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
        print('$filePath deleted successfully');
      }
    } catch (e) {
      print('Error while deleting file: $e');
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    }
  }

  Future<bool> _willPopCallback() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomeScreen()));
    return Future.value(true);
  }
}
