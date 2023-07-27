import 'package:document_organiser/database/bookmark.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'bookmarkedImages.dart';
import 'bookmarkedPdfs.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  Box<Bookmark> bookmarkBox = Hive.box<Bookmark>("bookmark");

  @override
  Widget build(BuildContext context) {
    List<Bookmark> bookmarkedImages = bookmarkBox.values.toList();

    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Document Organizer'),
            bottom: TabBar(
              tabs: [
                Tab(text: 'Images',),
                Tab(text: 'PDFs'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              BookmarkedImages(),
              BookmarkedPDFs(),
            ],
          ),
        ));
  }
}



