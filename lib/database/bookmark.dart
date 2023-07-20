import 'package:hive/hive.dart';
part 'bookmark.g.dart';

@HiveType(typeId: 0)
class Notes extends HiveObject{
  @HiveField(0)
  late String imagePath;

  @HiveField(1)
  late String pdfPath;

  Notes({required this.imagePath, required this.pdfPath});

}