import 'package:hive/hive.dart';
part 'password.g.dart';

@HiveType(typeId: 0)
class Password extends HiveObject{
  @HiveField(0)
  late String password;

  Password({required this.password});
}