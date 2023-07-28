import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../utils/constants.dart';
import 'bookmark_screen.dart';
import 'category_insider.dart';
import 'home_screen.dart';

class PdfPreview extends StatefulWidget {
  late String PdfPath;
  late List PdfList;
  late int index;
  String fromWhere = "";
  String category = "";

  PdfPreview.forDelete(
      {super.key,
      required this.PdfPath,
      required this.PdfList,
      required this.index,
      required this.fromWhere});

  PdfPreview.withCategory(
      {super.key,
      required this.PdfPath,
      required this.PdfList,
      required this.index,
      required this.fromWhere,
      required this.category});

  // PdfPreview.forShare({super.key, required this.PdfPath});

  @override
  State<PdfPreview> createState() => _PdfPreviewState();
}

class _PdfPreviewState extends State<PdfPreview> {
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
              "PDF Preview",
              style: kAppbarStyle,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () async {
                Share.shareFiles(
                  [widget.PdfPath],
                  // text: "jay",
                  //     // "Note : ${notesBox.get(widget.PdfPath)}",
                );
                print(notesBox.get(widget.PdfPath));
              },
              icon: Image.asset(
                'assets/images/share.png',
              ),
            ),
            IconButton(
              onPressed: () async {
                setState(() {});
                // show the info for the image
                print("widget.filePath ${widget.PdfPath.toString()}");

                if (await notesBox.get(widget.PdfPath) != null) {
                  String data = await notesBox.get(widget.PdfPath);

                  _openBottomDialog(context, data, widget.PdfPath);
                } else {
                  String data = "";
                  _openBottomDialog(context, data, widget.PdfPath);
                }
              },
              icon: Image.asset(
                'assets/images/info1.png',
              ),
            ),
            IconButton(
              onPressed: () async {
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
                              deleteFile(widget.PdfPath, widget.index);
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
              icon: Image.asset(
                'assets/images/delete.png',
              ),
            ),
          ],
        ),
        body: SfPdfViewer.file(File(widget.PdfPath)),
      ),
    );
  }

  Future<void> deleteFile(String filePath, int index) async {
    try {
      File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        setState(() {
          widget.PdfList.removeAt(index);
          widget.PdfList.remove(file); // Remove the deleted file from the list
        });
        // widget.imageFiles.removeAt(index);

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
                  categoryLabel: widget.category, isFromCategories: false)));
    } else if (widget.fromWhere == "bookmark") {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => BookmarkScreen()));
    }
    return Future.value(true);
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
                              text: notesBox.get(widget.PdfPath));

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
                                        await notesBox.put(widget.PdfPath,
                                            editingController.text);

                                        // retrieve that saved data
                                        data =
                                            await notesBox.get(widget.PdfPath);

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
}
