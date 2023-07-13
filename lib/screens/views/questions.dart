import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Questions extends StatefulWidget {
  const Questions({super.key});

  @override
  State<Questions> createState() => _QuestionsState();
}

class _QuestionsState extends State<Questions> {
  var Questions = [
    "Where were you born?",
    "What is the name of your BFF?",
    "What is name of your first school?",
    "What was your childhood nickname?",
    "What is your neighbour's name?"
  ];

  var q1 = "", q2 = "", q3 = "", q4 = "", q5 = "";

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  loadQuestions() async {
    var box3 = await Hive.openBox("Question");
    box3.put("question1", Questions[0]);
    box3.put("question2", Questions[1]);
    box3.put("question3", Questions[2]);
    box3.put("question4", Questions[3]);
    box3.put("question5", Questions[4]);

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
        body: Column(
          children: [
            Text(q1),
            Text(q2),
            Text(q3),
            Text(q4),
            Text(q5),
          ],
        ),
      ),
    );
  }
}

