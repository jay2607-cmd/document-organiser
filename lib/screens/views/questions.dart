import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

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

    setState(() async{
      await box3.put("index", 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Security Question"),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Text(
                    "Answer one of these questions for security purpose :-",
                    style: kQuestionStyle,
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  buildDropdownButtonFormField(),

                  const SizedBox(
                    height: 20,
                  ),
                  buildTextField(answer),
                  // buildRow(answer1)
                ],
              ),

              ElevatedButton(
                  onPressed: () async {

                    // save this value to database
                    var box3 = await Hive.openBox("Question");
                    box3.put("answer", answer.text);

                    print("answer from database : ${box3.get("answer")}");
                    print("answer from list : ${answer.text}");

                    String answerText = answer.text;

                    if (answerText.trim().isNotEmpty) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()));
                      answer.clear();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("PLease Answer the Question"),
                            duration: Duration(seconds: 2)),
                      );
                    }
                  },
                  child: const Text("Proceed"))
            ],
          ),
        ),
      ),
    );
  }

  TextField buildTextField(TextEditingController answer) {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(10)),
        hintText: 'Answer',
        // helperText: 'Keep it meaningful for future purposes',
        labelText: '${selectedValue.toString()}',
        prefixIcon: const Icon(
          Icons.question_answer,
          color: Colors.blue,
        ),
      ),
      controller: answer,
    );
  }

  Padding buildDropdownButtonFormField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          isExpanded: true,
          value: selectedValue,
          // style: TextStyle(fontFamily: 'Montserrat', color: Colors.black),
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
    );
  }
}
