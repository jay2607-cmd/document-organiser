import 'package:document_organiser/screens/views/pdf_preview.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pdf_thumbnail/pdf_thumbnail.dart';

import '../../database/bookmark.dart';

class BookmarkedPDFs extends StatefulWidget {
  const BookmarkedPDFs({super.key});

  @override
  State<BookmarkedPDFs> createState() => _BookmarkedPDFsState();
}

class _BookmarkedPDFsState extends State<BookmarkedPDFs> {
  Box<Bookmark> bookmarkBox = Hive.box<Bookmark>('bookmark');

  @override
  Widget build(BuildContext context) {
    List<Bookmark> bookmarkedImages = bookmarkBox.values.toList();

    return bookmarkedImages.isEmpty
        ? Center(
            child: Text('No Bookmarked PDFs'),
          )
        : ListView.builder(
            itemCount: bookmarkedImages.length,
            itemBuilder: (BuildContext context, int index) {
              Bookmark bookmark = bookmarkedImages[index];
              bool isBookmarked = bookmarkBox.values
                  .any((bookmark) => bookmark.path == bookmark.path);

              return bookmark.path.split("/").last.contains(".pdf")
                  ? GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfPreview.forDelete(
                              PdfPath: bookmark.path,
                              index: index,
                              PdfList: bookmarkedImages,
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
                                Container(
                                  height: 100,
                                  width: 80,
                                  child: PdfThumbnail.fromFile(
                                    bookmark.path,
                                    currentPage: 1,
                                    height: 100,
                                    currentPageDecoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.transparent)),
                                    backgroundColor: Colors.transparent,
                                    onPageClicked: (page) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PdfPreview.forDelete(
                                            PdfPath: bookmark.path,
                                            index: index,
                                            PdfList: bookmarkedImages,
                                            fromWhere: "bookmark",
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 35.0),
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: SingleChildScrollView(scrollDirection: Axis.horizontal,child: Text(bookmark.path.substring(70))),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 25.0),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: IconButton(
                                      onPressed: () {
                                        if (isBookmarked) {
                                          bookmarkBox.deleteAt(bookmarkBox.values
                                              .toList()
                                              .indexWhere((bookmark) =>
                                                  bookmark.path == bookmark.path));
                                        } else {
                                          bookmarkBox
                                              .add(Bookmark(path: bookmark.path));
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
                                )
                              ],
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
