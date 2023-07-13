import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:hive/hive.dart';

import '../provider/db_provider.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
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
              onChanged:  (bool value) async {

                var box2 = await Hive.openBox("Password");
                // box2.put("password", "2607");

                var value2 = box2.get("password");

                print(value2);
                setState(() {
                  if (_secured) {
                    screenLock(
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
                        },
                        child: const Text('Forgot Password'),
                      ),
                    );
                  } else {
                    final controller = InputController();
                    screenLockCreate(
                      context: context,
                      inputController: controller,
                      onConfirmed: (matchedText) async{

                        box2 = await Hive.openBox("Password");
                        box2.put("password", matchedText.toString());

                        setState(() {
                          _secured = true;
                        });
                        Navigator.of(context).pop();
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
          )


        ],
      ),
    );
  }
}
