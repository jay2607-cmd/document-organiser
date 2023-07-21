import 'package:flutter/material.dart';

import '../provider/db_provider.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool isNotesSharingEnabled = false;
  bool isHideCreationDate = false;
  bool isEmptyCategories = false;

  @override
  void initState() {
    super.initState();

    DbProvider().getSharingNotesState().then((value) {
      setState(() {
        isNotesSharingEnabled = value;
      });
    });

    DbProvider().getHideCreationDateStatus().then((value) {
      setState(() {
        isHideCreationDate = value;
      });
    });

    DbProvider().getEmptyCategories().then((value) {
      setState(() {
        isEmptyCategories = value;
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
        ),
        body: Column(
          children: [
            ListTile(
              title: Text("Share Document Details too"),
              trailing: Switch(
                  value: isNotesSharingEnabled,
                  onChanged: (bool value) async {
                    setState(() {
                      isNotesSharingEnabled = value;
                    });

                    DbProvider().saveSharingNotesState(value);
                  }),
            ),

            ListTile(
              title: Text("Hide Creation date of Documents"),
              trailing: Switch(
                  value: isHideCreationDate,
                  onChanged: (bool value) async {
                    setState(() {
                      isHideCreationDate = value;
                    });
                    DbProvider().saveHideCreationDateStatus(value);
                  }),
            ),

            ListTile(
              title: Text("Hide Empty Categories"),
              trailing: Switch(
                  value: isEmptyCategories,
                  onChanged: (bool value) async {
                    setState(() {
                      isEmptyCategories = value;
                    });
                    DbProvider().saveEmptyCategories(value);
                  }),
            ),

          ],
        ));
  }
}
