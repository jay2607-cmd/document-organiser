import 'package:hive/hive.dart';
part 'outer_count_db.g.dart';

@HiveType(typeId: 0)
class OuterCount extends HiveObject{
  @HiveField(0)
  late int count;

  OuterCount({required this.count});
}