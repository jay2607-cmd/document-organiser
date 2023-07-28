import 'package:document_organiser/database/bookmark.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../utils/constants.dart';
import 'bookmarkedImages.dart';
import 'bookmarkedPdfs.dart';
import 'category_insider.dart';

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
                "Bookmarked Docs",
                style: kAppbarStyle,
              ),
            ),
            bottom: TabBar(
              unselectedLabelColor: Colors.black,
              indicator: MyTabIndicator(overlayColor: Color(0xff4F6DDC)),
              padding: EdgeInsets.symmetric(
                horizontal: 17.5,
              ),
              tabs: [
                Tab(
                  height: 50,
                  child: Text(
                    "Images",
                    style: kUpperTabBarTextStyle,
                  ),
                ),
                Tab(
                  height: 50,
                  child: Text(
                    "PDFs",
                    style: kUpperTabBarTextStyle,
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: BookmarkedImages(),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: BookmarkedPDFs(),
              ),
            ],
          ),
        ));
  }
}



