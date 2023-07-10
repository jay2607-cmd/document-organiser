import 'dart:io';

import 'package:document_organiser/screens/views/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';


class ImagePreview extends StatefulWidget {
  final List<File> imageFiles;
  final int index;
  final String filePath;
  final File file;


  const ImagePreview(
      {super.key,
      required this.filePath,
      required this.file,
      required this.imageFiles,
      required this.index,
      });

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  @override
  Widget build(BuildContext context) {
    print(widget.filePath);
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
              Text(widget.file.path.substring(70)),

              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            Share.shareFiles([widget.filePath],
                                text: widget.filePath.substring(70));
                          },
                          icon: Icon(Icons.share),
                          label: Text(""),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: Container(
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xffFF5959)),
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
                          label: Text(
                            "",
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
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
        // widget.imageFiles.removeAt(index);

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
