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
  Categories.withLength(int this.totalLength, Map this.identifier);

  @override
  State<Categories> createState() => CategoriesState();
}

var categoryList = [
  "Invoice",
  "Personal",
  "Bank",
  "Medical",
  "Business",
  "Ticket",
  "Water",
  "Electricity",
  "Gas",
  "Book",
  "Book",
  "School",
  "Product",
  "Contract"
];

class CategoriesState extends State<Categories> {
  TextEditingController categoryController = TextEditingController();
  var data;
  List<int> dataLegnth = [];
  var outerCountBox;

  @override
  void initState() {
    isLogin();
    super.initState();
    loadCountFromDatabase();
  }

  Future<void> isLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("isFirst") == null) {
      var data = Save(name: "Invoice", image: outerCountBox.get("Invoice").toString());
      var box = Boxes.getData();
      box.add(data);

      print("outerCountBox.get(Invoice).toString() ${outerCountBox.get("Invoice").toString()}");

      data = Save(name: "Personal", image: outerCountBox.get("Personal").toString());
      box = Boxes.getData();
      box.add(data);

      data = Save(name: "Bank", image: outerCountBox.get("Bank").toString());
      box = Boxes.getData();
      box.add(data);

      data = Save(name: "Medical", image: outerCountBox.get("Medical").toString());
      box = Boxes.getData();
      box.add(data);

      data = Save(name: "Business", image: outerCountBox.get("Business").toString());
      box = Boxes.getData();
      box.add(data);

      data = Save(name: "Ticket", image: outerCountBox.get("Ticket").toString());
      box = Boxes.getData();
      box.add(data);

      data = Save(name: "Water", image: outerCountBox.get("Water").toString());
      box = Boxes.getData();
      box.add(data);

      data = Save(name: "Electricity", image: outerCountBox.get("Electricity").toString());
      box = Boxes.getData();
      box.add(data);

      data = Save(name: "Gas", image: outerCountBox.get("Gas").toString());
      box = Boxes.getData();
      box.add(data);

      data = Save(name: "Book", image: outerCountBox.get("Book").toString());
      box = Boxes.getData();
      box.add(data);

      data = Save(name: "School", image: outerCountBox.get("School").toString());
      box = Boxes.getData();
      box.add(data);

      data = Save(name: "Product", image: outerCountBox.get("Product").toString());
      box = Boxes.getData();
      box.add(data);

      data = Save(name: "Contract", image: outerCountBox.get("Contract").toString());
      box = Boxes.getData();
      box.add(data);

      print(box.get("name"));

      prefs.setBool("isFirst", true);
    } else {
      if (prefs.getBool("isFirst")! == false) {
        var data = Save(name: "Invoice", image: outerCountBox.get("Invoice").toString());
        var box = Boxes.getData();
        box.add(data);

        print("outerCountBox.get(Invoice).toString() ${outerCountBox.get("Invoice").toString()}");

        data = Save(name: "Personal", image: outerCountBox.get("Personal").toString());
        box = Boxes.getData();
        box.add(data);

        data = Save(name: "Bank", image: outerCountBox.get("Bank").toString());
        box = Boxes.getData();
        box.add(data);

        data = Save(name: "Medical", image: outerCountBox.get("Medical").toString());
        box = Boxes.getData();
        box.add(data);

        data = Save(name: "Business", image: outerCountBox.get("Business").toString());
        box = Boxes.getData();

        box.add(data);

        data = Save(name: "Ticket", image: outerCountBox.get("Ticket").toString());
        box = Boxes.getData();
        box.add(data);

        data = Save(name: "Water",image: outerCountBox.get("Water").toString());
        box = Boxes.getData();
        box.add(data);

        data = Save(name: "Electricity", image: outerCountBox.get("Electricity").toString());
        box = Boxes.getData();
        box.add(data);

        data = Save(name: "Gas", image: outerCountBox.get("Gas").toString());
        box = Boxes.getData();
        box.add(data);

        data = Save(name: "Book", image: outerCountBox.get("Book").toString());
        box = Boxes.getData();
        box.add(data);

        data = Save(name: "School", image: outerCountBox.get("School").toString());
        box = Boxes.getData();
        box.add(data);

        data = Save(name: "Product", image: outerCountBox.get("Product").toString());
        box = Boxes.getData();
        box.add(data);

        data = Save(name: "Contract", image: outerCountBox.get("Contract").toString());
        box = Boxes.getData();
        box.add(data);
        print("hey ${box.get("name")}");

        prefs.setBool("isFirst", true);
      }
    }
  }



  var categoryMap = new Map();
  /*var categoryMap =  {
  outerCountBox = await Hive.openBox("OuterCount");

  "Invoice" : outerCountBox.get(categoryList[1]),
    "Personal" : ,
  };*/
  int count = 0;
  loadCountFromDatabase() async {
    // open the database for count
    outerCountBox = await Hive.openBox("OuterCount");

    SharedPreferences imageLengthPref = await SharedPreferences.getInstance();
    print(
        "Added value in database : ${"Personal"} ::::: ${imageLengthPref.getInt(categoryList[0])}");

/*    categoryMap[categoryList[0]] = outerCountBox.get(categoryList[0]);
    categoryMap[categoryList[1]] = outerCountBox.get(categoryList[1]);
    categoryMap[categoryList[2]] = outerCountBox.get(categoryList[2]);
    categoryMap[categoryList[3]] = outerCountBox.get(categoryList[3]);
    categoryMap[categoryList[4]] = outerCountBox.get(categoryList[4]);
    categoryMap[categoryList[5]] = outerCountBox.get(categoryList[5]);
    categoryMap[categoryList[6]] = outerCountBox.get(categoryList[6]);
    categoryMap[categoryList[7]] = outerCountBox.get(categoryList[7]);
    categoryMap[categoryList[8]] = outerCountBox.get(categoryList[8]);
    categoryMap[categoryList[9]] = outerCountBox.get(categoryList[9]);
    categoryMap[categoryList[10]] = outerCountBox.get(categoryList[10]);
    categoryMap[categoryList[11]] = outerCountBox.get(categoryList[11]);
    categoryMap[categoryList[12]] = outerCountBox.get(categoryList[12]);*/

    print(categoryList[2]);
    count = await outerCountBox.get("Invoice");
    print(
        "count >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${count}");

    print("outerCountBox.get(Invoice).toString() ${outerCountBox.get("Invoice").toString()}");

    setState(() {});
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
                                          categoryList.remove(categoryList.last);

                                          Navigator.pop(context);
                                          print("categoryList.last ${categoryList.length}");

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
                                /*widget.identifier!.containsKey(data[index].name)?""
                                    "(${widget.identifier?[data[index]]})"
                                    :"(0)",*/
                                // count != 0 ? "($count)" : "",
                              // outerCountBox.contains(data[index].name) ? outerCountBox.get(data[index].name).toString() : "0",

                                outerCountBox.get(data[index].name) == null ? "0":
                                "${outerCountBox.get(data[index].name).toString()} ",
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
                        categoryList.add(data.name);
                        print("categoryList.last ${categoryList.last}");
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

class InheritanceTrial extends CategoryInsiderState {
  CategoryInsiderState categoryInsiderState = CategoryInsiderState();
  int categoryLength() {
    print("categoryLength ${imageFiles.length}");
    return (imageFiles.length);
  }
}