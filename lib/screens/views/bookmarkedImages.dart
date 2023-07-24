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

  @override
  Widget build(BuildContext context) {
    List<Bookmark> bookmarkedImages = bookmarkBox.values.toList();

    return bookmarkedImages.isEmpty
        ? Center(
            child: Text('No Bookmarked Images'),
          )
        : ListView.builder(
            itemCount: bookmarkBox.length,
            itemBuilder: (BuildContext context, index) {
              String filePath = bookmarkedImages[index].path;
              bool isBookmarked = bookmarkBox.values
                  .any((bookmark) => bookmark.path == filePath);
              Bookmark bookmark = bookmarkedImages[index];

              return bookmark.path.split("/").last.contains(".png")
                  ? GestureDetector(
                      onTap: () {
                        print("${index}");
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImagePreview.withInfo(
                              updatedPath: bookmarkedImages[index].path,
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
            },
          );
  }
}
