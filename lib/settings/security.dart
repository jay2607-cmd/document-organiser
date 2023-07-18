import 'package:document_organiser/screens/views/forget_screen.dart';
import 'package:document_organiser/screens/views/questions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:hive/hive.dart';

import '../provider/db_provider.dart';

class Security extends StatefulWidget {
  const Security({super.key});

  @override
  State<Security> createState() => _SecurityState();
}

class _SecurityState extends State<Security> {
  bool _secured = false;

  @override
  void initState() {
    DbProvider().getAuthState().then((value) {
      setState(() {
        _secured = value;
      });
    });
    super.initState();
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
            title: Text("Secure Account"),
            subtitle: Text("Enable two factor authentication"),
            trailing: Switch(
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
                                builder: (context) => const Questions()));

                        setState(() {
                          _secured = true;
                        });
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
                DbProvider().saveAuthState(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
