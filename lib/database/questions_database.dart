import 'package:hive/hive.dart';
part 'questions_database.g.dart';

@HiveType(typeId: 0)
class QuestionDatabase extends HiveObject{
  @HiveField(0)
  late String question;

  QuestionDatabase({required this.question});
}