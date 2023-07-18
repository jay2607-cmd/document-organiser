import 'dart:io';

import 'package:document_organiser/boxes/boxes.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../database/save.dart';
import 'category_insider.dart';

class Categories extends StatefulWidget {
  // final bool isLoggedIn;
  Categories({super.key
      // required this.isLoggedIn,
      });

  int totalLength = 0;
  Map? identifier;
  Categories.withLength(int this.totalLength,Map this.identifier);

  @override
  State<Categories> createState() => CategoriesState();
}

class CategoriesState extends State<Categories> {
  TextEditingController categoryController = TextEditingController();
  var data;
  List<int> dataLegnth = [];

  @override
  void initState() {
    isLogin();
    super.initState();
  }

  Future<void> isLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("isFirst") == null) {
      var data = Save(name: "Invoice", image: "");
      var box = Boxes.getData();
      box.add(data);

      data = Save(name: "Personal", image: "");
      box = Boxes.getData();
      box.add(data);

      data = Save(name: "Bank", image: "");
      box = Boxes.getData();
      box.add(data);

      data = Save(name: "Medical", image: "");
      box = Boxes.getData();
      box.add(data);

      data = Save(name: "Business", image: "");
      box = Boxes.getData();
      box.add(data);

      data = Save(name: "Ticket", image: "");
      box = Boxes.getData();
      box.add(data);

      data = Save(name: "Water", image: "");
      box = Boxes.getData();
      box.add(data);

      data = Save(name: "Electricity", image: "");
      box = Boxes.getData();
      box.add(data);

      data = Save(name: "Gas", image: "");
      box = Boxes.getData();
      box.add(data);

      data = Save(name: "Book", image: "");
      box = Boxes.getData();
      box.add(data);

      data = Save(name: "School", image: "");
      box = Boxes.getData();
      box.add(data);

      data = Save(name: "Product", image: "");
      box = Boxes.getData();
      box.add(data);

      data = Save(name: "Contract", image: "");
      box = Boxes.getData();
      box.add(data);

      print(box.get("name"));

      prefs.setBool("isFirst", true);
    } else {
      if (prefs.getBool("isFirst")! == false) {
        var data = Save(name: "Invoice", image: "");
        var box = Boxes.getData();
        box.add(data);

        data = Save(name: "Personal", image: "");
        box = Boxes.getData();
        box.add(data);

        data = Save(name: "Bank", image: "");
        box = Boxes.getData();
        box.add(data);

        data = Save(name: "Medical", image: "");
        box = Boxes.getData();
        box.add(data);

        data = Save(name: "Business", image: "");
        box = Boxes.getData();

        box.add(data);

        data = Save(name: "Ticket", image: "");
        box = Boxes.getData();
        box.add(data);

        data = Save(name: "Water", image: "");
        box = Boxes.getData();
        box.add(data);

        data = Save(name: "Electricity", image: "");
        box = Boxes.getData();
        box.add(data);

        data = Save(name: "Gas", image: "");
        box = Boxes.getData();
        box.add(data);

        data = Save(name: "Book", image: "");
        box = Boxes.getData();
        box.add(data);

        data = Save(name: "School", image: "");
        box = Boxes.getData();
        box.add(data);

        data = Save(name: "Product", image: "");
        box = Boxes.getData();
        box.add(data);

        data = Save(name: "Contract", image: "");
        box = Boxes.getData();
        box.add(data);
        print("hey ${box.get("name")}");

        prefs.setBool("isFirst", true);
      }
    }
  }

  InheritanceTrial inheritanceTrial = InheritanceTrial();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<Box<Save>>(
        valueListenable: Boxes.getData().listenable(),
        builder: (context, box, _) {
          data = box.values.toList().cast<Save>();
          // dataLegnth.length =  data.length;
          print("INdetifie length ${widget.identifier!.length}");
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemCount: box.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryInsider(
                        categoryLabel: data[index].name,
                      ),
                    ),
                  );
                },
                child: Card(
                  color: Color(0xffF6F7F8),
                  child: Container(
                    color: Colors.blue.shade200,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text("${data[index].name} ",
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: IconButton(
                            iconSize: 20,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Warning!',
                                        style: TextStyle(color: Colors.red)),
                                    content: const Text(
                                        'Do you really want to delete this Category!'),
                                    actions: [
                                      TextButton(
                                        child: Text('Cancel'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      TextButton(
                                        child: Text('OK'),
                                        onPressed: () {
                                          delete(data[index]);
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );

                              setState(() {});
                            },
                            icon: Icon(Icons.delete),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),

                            child: Text(
                                widget.identifier!.containsKey(data[index].name)?""
                                    "(${widget.identifier?[data[index]]})"
                                    :"(0)",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        )
                        // SizedBox(
                        //   height: 4,
                        // ),
                        // Text(
                        //     "Date  :  ${data[reversedIndex].date.toString()}",
                        //     style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Add Category!',
                    style: TextStyle(color: Colors.blue)),
                content: const Text('Do you really want to Add New Category!'),
                actions: [
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(10)),
                      hintText: 'Enter New Category',
                      helperText: 'Keep it meaningful',
                      labelText: 'Add Category',
                      prefixIcon: const Icon(
                        Icons.drive_file_rename_outline_rounded,
                        color: Colors.blue,
                      ),
                    ),
                    controller: categoryController,
                  ),
                  TextButton(
                    child: Text('Add'),
                    onPressed: () async {
                      Navigator.pop(context);
                      print(categoryController);

                      var data = Save(name: categoryController.text, image: "");
                      var box = Boxes.getData();
                      bool categoryExists = box.values.any((item) =>
                          item.name.toLowerCase() == data.name.toLowerCase());
                      if (categoryExists) {
                        showInSnackBar("Category already exists!");
                        return; // Don't add the category if it already exists
                      } else if (categoryController.text.trim().isEmpty) {
                        showInSnackBar("Category Cannot be Empty");
                      } else {
                        box.add(data);
                      }

                      setState(() {});
                      categoryController.clear();
                    },
                  ),
                ],
              );
            },
          );
        },
        label: Text("New Category"),
        icon: Icon(Icons.add),
      ),
    );
  }

  void delete(Save save) async {
    print(save);
    await save.delete();

    // Hive.box("SaveModel").clear();
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ));
  }
}


class InheritanceTrial extends CategoryInsiderState{
  CategoryInsiderState categoryInsiderState = CategoryInsiderState();
  int categoryLength() {
    print("categoryLength ${imageFiles.length}");
    return (imageFiles.length);
  }
}