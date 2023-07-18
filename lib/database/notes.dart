import 'package:hive/hive.dart';
part 'notes.g.dart';

@HiveType(typeId: 0)
class Notes extends HiveObject{
  @HiveField(0)
  late String notes;

  Notes({required this.notes});
}