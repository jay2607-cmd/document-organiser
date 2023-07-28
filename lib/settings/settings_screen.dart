import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

import '../provider/db_provider.dart';
import '../screens/views/forget_screen.dart';
import '../screens/views/questions.dart';
import '../utils/constants.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool isNotesSharingEnabled = false;
  bool isHideCreationDate = false;
  bool _secured = false;

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

    DbProvider().getAuthState().then((value) {
      setState(() {
        _secured = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Set the default text style to Montserrat
        useMaterial3: true,
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: IconButton(
                icon: Image.asset(
                  'assets/images/back.png',
                  height: 24,
                  width: 24,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                "Settings",
                style: kAppbarStyle,
              ),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Color(0xffF0F1F5),
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    title: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 24.0, horizontal: 8),
                      child: Text(
                        "Share Document Details too",
                        style: kSettingsTextStyle,
                      ),
                    ),
                    trailing: Transform.scale(
                      scale: 0.8,
                      child: Switch(
                          activeColor: Color(0xff4F6DDC),
                          activeTrackColor: Color(0xffDCE0ED),
                          inactiveThumbColor: Color(0xffA7B2C7),
                          inactiveTrackColor: Color(0xffDCE0ED),
                          value: isNotesSharingEnabled,
                          onChanged: (bool value) async {
                            setState(() {
                              isNotesSharingEnabled = value;
                            });

                            DbProvider().saveSharingNotesState(value);
                          }),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Color(0xffF0F1F5),
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    title: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 18.0, horizontal: 8),
                      child: Text("Hide Creation date of Documents",
                          style: kSettingsTextStyle),
                    ),
                    trailing: Transform.scale(
                      scale: 0.8,

                      child: Switch(
                          activeColor: Color(0xff4F6DDC),
                          activeTrackColor: Color(0xffDCE0ED),
                          inactiveThumbColor: Color(0xffA7B2C7),
                          inactiveTrackColor: Color(0xffDCE0ED),

                          value: isHideCreationDate,
                          onChanged: (bool value) async {
                            setState(() {
                              isHideCreationDate = value;
                            });
                            DbProvider().saveHideCreationDateStatus(value);
                          }),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                child: Container(
                  decoration: BoxDecoration(
                      color: Color(0xffF0F1F5),
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: ListTile(
                      title: Text(
                        "Secure Account",
                        style: kSettingsTextStyle,
                      ),
                      subtitle: Text(
                        "Enable two factor authentication",
                        style: kSettingsSubTextStyle,
                      ),
                      trailing: Transform.scale(
                        scale: 0.8,

                        child: Switch(
                          activeColor: Color(0xff4F6DDC),
                          activeTrackColor: Color(0xffDCE0ED),
                          inactiveTrackColor: Color(0xffDCE0ED),
                          inactiveThumbColor: Color(0xffA7B2C7),
                          value: _secured,
                          onChanged: (bool value) async {
                            var box2 = await Hive.openBox("Password");
                            // box2.put("password", "2607");

                            var value2 = box2.get("password");

                            print(value2);
                            setState(() {
                              if (_secured) {
                                screenLock(
                                  // canCancel: false,
                                  context: context,
                                  correctString: value2,
                                  maxRetries: 3,
                                  retryDelay: const Duration(seconds: 5),
                                  delayBuilder: (context, delay) => Text(
                                      "Cannot be entered for ${(delay.inMilliseconds / 1000).ceil()} seconds."),
                                  onUnlocked: () {
                                    setState(() {
                                      _secured = false;
                                      DbProvider().saveAuthState(_secured);
                                    });
                                    Navigator.pop(context);
                                  },
                                  footer: TextButton(
                                    onPressed: () {
                                      // Release the confirmation state and return to the initial input state.
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const ForgetPasswordScreen()));
                                    },
                                    child: const Text('Forgot Password'),
                                  ),
                                );
                              } else {
                                final controller = InputController();
                                screenLockCreate(
                                  // canCancel: false,
                                  context: context,
                                  inputController: controller,
                                  onConfirmed: (matchedText) async {
                                    box2 = await Hive.openBox("Password");
                                    box2.put("password", matchedText.toString());
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const Questions()));
                                  },
                                  footer: TextButton(
                                    onPressed: () {
                                      // Release the confirmation state and return to the initial input state.
                                      controller.unsetConfirmed();
                                    },
                                    child: const Text('Reset input'),
                                  ),
                                );
                              }
                              // code for reset
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
