import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../utils/constants.dart';
import 'home_screen.dart';

class Questions extends StatefulWidget {
  const Questions({super.key});

  @override
  State<Questions> createState() => QuestionsState();
}

TextEditingController answer1 = TextEditingController();
TextEditingController answer2 = TextEditingController();
TextEditingController answer3 = TextEditingController();
TextEditingController answer4 = TextEditingController();
TextEditingController answer5 = TextEditingController();

class QuestionsState extends State<Questions> {
  bool isConfirmed = false;

  static var questions = [
    "Where were you born?",
    "What is the name of your BFF?",
    "What is name of your first school?",
    "What was your childhood nickname?",
    "What is your neighbour's name?"
  ];

  static var answers = [
    answer1.text,
    answer2.text,
    answer3.text,
    answer4.text,
    answer5.text
  ];

  var q1 = "", q2 = "", q3 = "", q4 = "", q5 = "";

  /* var questionAnswerMap = {
    "Where were you born?": answer1.text,
    "What is the name of your BFF?": answer2.text,
    "What is name of your first school?": answer3.text,
    "What was your childhood nickname?": answer4.text,
    "What is your neighbour's name?": answer5.text
  };*/

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  loadQuestions() async {
    var box3 = await Hive.openBox("Question");
    box3.put("question1", questions[0]);
    box3.put("question2", questions[1]);
    box3.put("question3", questions[2]);
    box3.put("question4", questions[3]);
    box3.put("question5", questions[4]);

    setState(() {
      q1 = box3.get("question1");
      q2 = box3.get("question2");
      q3 = box3.get("question3");
      q4 = box3.get("question4");
      q5 = box3.get("question5");
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Security Question"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      "Answer one of these questions for security purpose :-",
                      style: kQuestionStyle,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "1. $q1",
                      style: kQuestionStyle,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    buildTextField(answer1, isConfirmed),
                    buildRow(answer1)
                  ],
                ),
                Column(
                  children: [
                    Text(
                      "2. $q2",
                      style: kQuestionStyle,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    buildTextField(answer2, isConfirmed),
                    buildRow(answer2)
                  ],
                ),
                Column(
                  children: [
                    Text(
                      "3. $q3",
                      style: kQuestionStyle,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    buildTextField(answer3, isConfirmed),
                    buildRow(answer3)
                  ],
                ),
                Column(
                  children: [
                    Text(
                      "4. $q4",
                      style: kQuestionStyle,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    buildTextField(answer4, isConfirmed),
                    buildRow(answer4)
                  ],
                ),
                Column(
                  children: [
                    Text(
                      "5. $q5",
                      style: kQuestionStyle,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    buildTextField(answer5, isConfirmed),
                    buildRow(answer5)
                  ],
                ),
                ElevatedButton(
                    onPressed: () async {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomeScreen()));

                      // print(answer1.text);
                      // print(answer2.text);
                      // print(answer3.text);
                      // print(answer4.text);
                      // print(answer5.text);

                      // save this value to database
                      var box3 = await Hive.openBox("Question");
                      box3.put("answer1", answers[0]);
                      box3.put("answer2", answers[1]);
                      box3.put("answer3", answers[2]);
                      box3.put("answer4", answers[3]);
                      box3.put("answer5", answers[4]);

                      print("answer from database : ${box3.get("answer1")}");
                      print("answer from list : ${answers[0]}");
                      print("answer from list : ${answers[1]}");
                      print("answer from list : ${answers[2]}");
                      print("answer from list : ${answers[3]}");
                      print("answer from list : ${answers[4]}");

                      /*int i = 0;
                      while (i < 5) {
                        if (answers[i] != "") {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomeScreen()));
                          break;
                        }
                        else{
                          print("empty");
                          break;
                        }
                      }*/

                      if (answer1.text.isNotEmpty) {
                        box3.put("index", 1);
                        print(1);
                      }
                      if (answer2.text.isNotEmpty) {
                        print(2);
                        box3.put("index", 2);
                      }
                      if (answer3.text.isNotEmpty) {
                        box3.put("index", 3);
                      }
                      if (answer4.text.isNotEmpty) {
                        box3.put("index", 4);
                        print(4);
                      }
                      if (answer5.text.isNotEmpty) {
                        box3.put("index", 5);
                        print(5);
                      } else {
                        box3.put("index", 1);
                        print(-1);
                      }

                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()));
                    },
                    child: Text("Proceed"))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row buildRow(TextEditingController answer) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
            onPressed: () {
              if (answer.text.trim() != "") {
                isConfirmed = true;

                setState(() {});
              }
            },
            child: Text("Confirm")),
        ElevatedButton(
            onPressed: () {
              isConfirmed = false;
              setState(() {});
            },
            child: Text("Retry")),
      ],
    );
  }

  TextField buildTextField(
      TextEditingController answer, bool isConfirmedParameter) {
    return TextField(
      enabled: isConfirmedParameter ? false : true,
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
