
import 'package:document_organiser/database/outer_count_db.dart';
import 'package:hive/hive.dart';



class OuterCountBox{
  static Box<OuterCount> getData() => Hive.box<OuterCount>("OuterCount");
}