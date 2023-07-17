import 'package:hive/hive.dart';
part 'save.g.dart';

@HiveType(typeId: 0)
class Save extends HiveObject{
  @HiveField(0)
  late String name;

  @HiveField(1)
  late String image;

  Save({required this.name, required this.image});
}