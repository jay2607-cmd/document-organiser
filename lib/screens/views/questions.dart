import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../provider/db_provider.dart';
import '../../utils/constants.dart';
import 'home_screen.dart';

class Questions extends StatefulWidget {
  const Questions({super.key});

  @override
  State<Questions> createState() => QuestionsState();
}

TextEditingController answer = TextEditingController();

var box3;

class QuestionsState extends State<Questions> {
  bool isConfirmed = false;

  int index = 1;

  String? selectedValue;

  QuestionsState() {
    selectedValue = questions[0];
  }

  final questions = [
    "Where were you born?",
    "What is the name of your BFF?",
    "What is name of your first school?",
    "What was your childhood nickname?",
    "What is your neighbour's name?"
  ];

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  loadQuestions() async {
    box3 = await Hive.openBox("Question");
    box3.put("question1", questions[0]);
    box3.put("question2", questions[1]);
    box3.put("question3", questions[2]);
    box3.put("question4", questions[3]);
    box3.put("question5", questions[4]);
    await box3.put("index", 1);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
              "Security Question",
              style: kAppbarStyle,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 35.0, vertical: 25),
                      child: Column(
                        children: [
                          Text(
                            "Answer One of These questions for",
                            style: kQuestionStyle,
                          ),
                          Text(
                            "Security Purpose",
                            style: kQuestionStyle,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // buildRow(answer1)
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xffF0F1F5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      buildDropdownButtonFormField(),
                      const SizedBox(
                        height: 12,
                      ),
                      buildTextField(answer),
                      const SizedBox(
                        height: 12,
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
                            onPressed: () async {
                              // save this value to database
                              var box3 = await Hive.openBox("Question");
                              box3.put("answer", answer.text);

                              print(
                                  "answer from database : ${box3.get("answer")}");
                              print("answer from list : ${answer.text}");

                              String answerText = answer.text;

                              if (answerText.trim().isNotEmpty) {
                                DbProvider().saveAuthState(true);
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const HomeScreen()));
                                answer.clear();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Please Answer the Question"),
                                      duration: Duration(seconds: 2)),
                                );
                              }
                            },
                            child: const Text("Proceed")),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
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
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: kPurpleColor),
            borderRadius: BorderRadius.circular(10),
          ),
          border: InputBorder.none,
          hintText: 'Answer',
          labelText: '${selectedValue.toString()}',
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

  buildDropdownButtonFormField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            isExpanded: true,
            icon: Image.asset(
              "assets/images/dd.png",
              height: 20,
              width: 20,
            ),
            value: selectedValue,
            style: TextStyle(
                fontFamily: 'Montserrat', color: Colors.black, fontSize: 13),
            items: questions
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ))
                .toList(),
            onChanged: (val) {
              setState(
                () {
                  selectedValue = val as String;
                  for (int i = 0; i < questions.length; i++) {
                    if (questions[i] == selectedValue.toString()) {
                      index = i + 1;
                      box3.put("index", index);
                      print("index $index");
                    }
                  }
                  // selectedValue = newData;
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
