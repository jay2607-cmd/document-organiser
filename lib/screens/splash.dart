// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:document_organiser/screens/views/forget_screen.dart';
import 'package:document_organiser/screens/views/home_screen.dart';
import 'package:document_organiser/screens/views/questions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:hive/hive.dart';

import '../provider/db_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
        const Duration(milliseconds: 1500),
        () => DbProvider().getAuthState().then((value) async {
              if (value == false) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => HomeScreen()));
              } else {
                print("show authentication");

                /*    Navigator.push(
                    context,
                    PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          PasscodeScreen(
                        title: Text(
                          'Enter App Passcode',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 28),
                        ),
                        passwordEnteredCallback: _onPasscodeEntered,
                        cancelButton: Icon(
                          Icons.arrow_back,
                          color: Colors.blue,
                        ),
                        deleteButton: Text(
                          'Delete',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                          semanticsLabel: 'Delete',
                        ),
                        shouldTriggerVerification: _verificationNotifier.stream,
                        backgroundColor: Colors.black.withOpacity(0.8),
                        cancelCallback: _onPasscodeCancelled,
                        passwordDigits: 6,
                        bottomWidget: _buildPasscodeRestoreButton(),
                      ),
                    ));*/
                var box2 = await Hive.openBox("Password"

                    // ignore: use_build_context_synchronously
                    );

                var value2 = box2.get("password");

                screenLock(
                  context: context,
                  correctString: value2,
                  maxRetries: 3,
                  retryDelay: const Duration(seconds: 5),
                  delayBuilder: (context, delay) => Text(
                      "Cannot be entered for ${(delay.inMilliseconds / 1000).ceil()} seconds."),
                  onUnlocked: () {
                    Navigator.pop(context);
                    // Navigator.of(context)
                    //     .pushReplacement(MaterialPageRoute(builder: (context) => const HomeScreen()));
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => HomeScreen()));
                  },
                  canCancel: false,
                  footer: TextButton(
                    onPressed: () {
                      // Release the confirmation state and return to the initial input state.
                      // controller.unsetConfirmed();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => ForgetPasswordScreen()));
                    },
                    child: const Text('Forgot Password'),
                  ),
                );
              }
            }));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image(image: AssetImage("assets/images/splash_icon.png",),height: 155, width: 155,),
            // SizedBox(height: 30,),
            Text(
              "Document",
              style: TextStyle(fontSize: 35),
            ),
            Text(
              "Organiser",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
            ),
          ],
        ),
      ),
    );
  }
}
