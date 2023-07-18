import 'package:document_organiser/database/notes.dart';
import 'package:hive/hive.dart';


class Boxes{
  static Box<Notes> getData() => Hive.box<Notes>("Notes");
}