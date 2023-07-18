import 'package:document_organiser/database/save.dart';
import 'package:document_organiser/screens/authentication.dart';
import 'package:document_organiser/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

/*
  var directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);

  Hive.registerAdapter(SaveAdapter());

  await Hive.openBox<Save>("save");
*/

  var directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);

  Hive.registerAdapter(SaveAdapter());

  await Hive.openBox<Save>("saveCategories");

  // for bookmark
  await Hive.initFlutter();
  await Hive.openBox("favorites");

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Document Organiser',
      home: SplashScreen(),
    );
  }
}
