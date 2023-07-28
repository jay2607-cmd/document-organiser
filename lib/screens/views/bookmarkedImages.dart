import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../database/bookmark.dart';
import 'image_preview.dart';

class BookmarkedImages extends StatefulWidget {
  @override
  State<BookmarkedImages> createState() => _BookmarkedImagesState();
}

class _BookmarkedImagesState extends State<BookmarkedImages> {
  Box<Bookmark> bookmarkBox = Hive.box<Bookmark>('bookmark');

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

  @override
  Widget build(BuildContext context) {
    List<Bookmark> bookmarkedImages = bookmarkBox.values.toList();
    List<File> imageFiles = [];

    return bookmarkedImages.isEmpty
        ? Center(
            child: Text('No Bookmarked Images'),
          )
        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: bookmarkBox.length,
                  itemBuilder: (BuildContext context, index) {
                    String filePath = bookmarkedImages[index].path;
                    bool isBookmarked = bookmarkBox.values
                        .any((bookmark) => bookmark.path == filePath);
                    Bookmark bookmark = bookmarkedImages[index];

                    return bookmark.path.split("/").last.contains(".png")
                        ? GestureDetector(
                            onTap: () {
                              File file = File(filePath);
                              imageFiles.add(file);

                              print("${index}");
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ImagePreview(
                                    index: index,
                                    file: file,
                                    filePath: filePath,
                                    imageFiles: imageFiles,
                                    fromWhere: "bookmark",
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
                                          width: 70,
                                          child: Image.file(File(filePath)),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 12.0, left: 8),
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Text(filePath.substring(70)),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: IconButton(
                                          onPressed: () {
                                            bookmarkBox.deleteAt(bookmarkBox.values
                                                .toList()
                                                .indexWhere((bookmark) =>
                                                    bookmark.path == filePath));

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
                          )
                        : SizedBox.shrink();
                  },
                ),
              ),
            ],
          );

    /*itemCount: bookmarkBox.length,
            itemBuilder: (BuildContext context, index) {
              String filePath = bookmarkedImages[index].path;
              bool isBookmarked = bookmarkBox.values
                  .any((bookmark) => bookmark.path == filePath);
              Bookmark bookmark = bookmarkedImages[index];

              return bookmark.path.split("/").last.contains(".png")
                  ? GestureDetector(
                      onTap: () {
                        File file = File(filePath);
                        imageFiles.add(file);

                        print("${index}");
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImagePreview(
                              index: index,
                              file: file,
                              filePath: filePath,
                              imageFiles: imageFiles,
                              fromWhere: "bookmark",
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
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 100,
                                    width: 100,
                                    child: Image.file(File(filePath)),
                                  ),
                                  Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 12.0, left: 6),
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Text(filePath.substring(70)),
                                        ),
                                      ),
                                      // Add the last modified date here if needed
                                    ],
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      bookmarkBox.deleteAt(bookmarkBox.values
                                          .toList()
                                          .indexWhere((bookmark) =>
                                              bookmark.path == filePath));

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
                    )
                  : SizedBox.shrink();
            },*/
  }
}
