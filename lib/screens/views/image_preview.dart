import 'dart:io';

import 'package:document_organiser/screens/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';

class ImagePreview extends StatefulWidget {
  List<File> imageFiles = [];
  int index = 0;
  String filePath = "";
  File? file;

  ImagePreview({
    super.key,
    required this.filePath,
    required this.file,
    required this.imageFiles,
    required this.index,
  });

  String updatedPath = "";
  ImagePreview.withInfo({super.key, required this.updatedPath});

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  late TextEditingController editingController;

  @override
  void initState() {
    super.initState();
    openBox();
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
                            Share.shareFiles([widget.filePath],
                                text: widget.filePath.substring(70));
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
                                        setState(() {
                                          deleteFile(
                                              widget.filePath, widget.index);
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
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
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

                                        print("Edited Date $data");

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
