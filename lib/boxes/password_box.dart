
import 'package:hive/hive.dart';

import '../database/password.dart';


class PasswordBoxes{
  static Box<Password> getData() => Hive.box<Password>("Password");
}