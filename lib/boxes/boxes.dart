import 'package:document_organiser/database/save.dart';
import 'package:hive/hive.dart';


class Boxes{
  static Box<Save> getData() => Hive.box<Save>("saveCategories");
}