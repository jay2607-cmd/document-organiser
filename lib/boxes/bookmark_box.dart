import 'package:hive/hive.dart';


class Bookmark{
  static Box<Bookmark> getData() => Hive.box<Bookmark>("bookmark");
}