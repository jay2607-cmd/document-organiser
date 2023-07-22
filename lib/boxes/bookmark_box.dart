import 'package:hive/hive.dart';

import '../database/bookmark.dart';


class BookmarkBox{
  static Box<Bookmark> getData() => Hive.box<Bookmark>("bookmark");
}