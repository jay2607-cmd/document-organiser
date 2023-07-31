import 'package:document_organiser/screens/views/layout_screen.dart';
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
            "Forget Password",
            style: kAppbarStyle,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25),
              child: Column(
                children: [
                  Text(
                    "Answer One of These questions to",
                    style: kQuestionStyle,
                  ),
                  Text(
                    "Reset Your Password",
                    style: kQuestionStyle,
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xffF0F1F5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      child: Text(
                        q,
                        style: kForgetQuestionStyle,
                      ),
                    ),
                    SizedBox(
                      height: 18,
                    ),
                    buildTextField(answerController),
                    SizedBox(
                      height: 18,
                    ),
                    Container(
                      height: 52,
                      width: double.infinity,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    7.0), // Set the desired border radius here
                              ),
                              backgroundColor: kPurpleColor),
                          onPressed: () {
                            print("answerController $answerController");

                            answerController.text.trim().toLowerCase() ==
                                    a.trim().toLowerCase()
                                ? screenLockCreate(
                                    // canCancel: false,
                                    context: context,
                                    inputController: controller,
                                    onConfirmed: (matchedText) async {
                                      box2 = await Hive.openBox("Password");
                                      box2.put(
                                          "password", matchedText.toString());

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            backgroundColor:
                                                Colors.blue.shade400,
                                            content: Text(
                                                "Password Reset Successfully"),
                                            duration: Duration(seconds: 2)),
                                      );

                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  LayoutScreen()));
                                    },
                                    footer: TextButton(
                                      onPressed: () {
                                        // Release the confirmation state and return to the initial input state.
                                        controller.unsetConfirmed();
                                      },
                                      child: const Text('Reset input'),
                                    ),
                                  )
                                : ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                    content: Text("Authentication failed"),
                                    duration: Duration(seconds: 2),
                                  ));
                          },
                          child: Text("Reset password")),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  buildTextField(TextEditingController answer) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: TextField(
        style: TextStyle(
            fontFamily: 'Montserrat', color: Colors.black, fontSize: 13),
        decoration: InputDecoration(
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: kPurpleColor),
            borderRadius: BorderRadius.circular(10),
          ),
          hintText: 'Answer',
          // helperText: 'Keep it meaningful for future purposes',
          labelText: q,
          labelStyle: TextStyle(
            color: kPurpleColor,
          ),
          prefixIcon: const Icon(
            Icons.question_answer,
            color: kPurpleColor,
          ),
        ),
        controller: answer,
      ),
    );
  }
}
