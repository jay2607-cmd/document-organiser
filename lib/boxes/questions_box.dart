
import 'package:hive/hive.dart';

import '../database/questions_database.dart';


class QuestionBoxes{
  static Box<QuestionDatabase> getData() => Hive.box<QuestionDatabase>("Question");
}