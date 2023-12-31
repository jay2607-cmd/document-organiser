import 'package:document_organiser/database/bookmark.dart';
import 'package:document_organiser/database/save.dart';
import 'package:document_organiser/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';

import 'package:google_fonts/google_fonts.dart';

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
  await Hive.initFlutter();

  Hive.registerAdapter(
    SaveAdapter(),
  );
  Hive.registerAdapter(BookmarkAdapter());

  await Hive.openBox<Save>("saveCategories");
  await Hive.openBox<Bookmark>("bookmark");

  // for bookmark
  await Hive.openBox("favorites");

  // for OuterCount
  await Hive.openBox("OuterCount");

  // for Notes
  await Hive.openBox("Notes");

  // for Password
  await Hive.openBox("Password");

  //for question
  await Hive.openBox("Question");

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Document Organiser',
      theme: ThemeData(
        // Set the default text style to Montserrat
        // useMaterial3: true,
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: SplashScreen(),
    );
  }
}
