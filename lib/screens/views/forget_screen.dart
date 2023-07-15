import 'package:document_organiser/screens/views/home_screen.dart';
import 'package:document_organiser/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:hive/hive.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  TextEditingController answerController = TextEditingController();

  String q = "";
  String a = "";
  var box2;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  loadQuestions() async {
    var box3 = await Hive.openBox("Question");

    setState(() {
      int index = box3.get("index");
      print("index $index");

      q = box3.get("question$index");
      a = box3.get("answer");
      print(a);
    });

    print(q);
    box2 = await Hive.openBox("Password");
  }

  @override
  Widget build(BuildContext context) {
    final controller = InputController();

    return Scaffold(
      appBar: AppBar(
        title: Text("Forget password"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              q,
              style: kQuestionStyle,
            ),
            SizedBox(
              height: 20,
            ),
            buildTextField(answerController),
            ElevatedButton(
                onPressed: () {
                  print("answerController $answerController");

                  answerController.text.trim().toLowerCase() == a.trim().toLowerCase()
                      ? screenLockCreate(
                          // canCancel: false,
                          context: context,
                          inputController: controller,
                          onConfirmed: (matchedText) async {
                            box2 = await Hive.openBox("Password");
                            box2.put("password", matchedText.toString());

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  backgroundColor: Colors.blue.shade400,
                                  content: Text("Password Reset Successfully"),
                                  duration: Duration(seconds: 2)),
                            );

                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomeScreen()));
                          },
                          footer: TextButton(
                            onPressed: () {
                              // Release the confirmation state and return to the initial input state.
                              controller.unsetConfirmed();
                            },
                            child: const Text('Reset input'),
                          ),
                        )
                      : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Authentication failed"),
                          duration: Duration(seconds: 2),
                        ));
                },
                child: Text("Reset password"))
          ],
        ),
      ),
    );
  }

  TextField buildTextField(TextEditingController answer) {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(10)),
        hintText: 'Answer',
        // helperText: 'Keep it meaningful for future purposes',
        labelText: 'Answer label',
        prefixIcon: const Icon(
          Icons.question_answer,
          color: Colors.blue,
        ),
      ),
      controller: answer,
    );
  }
}
