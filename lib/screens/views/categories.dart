import 'dart:io';

import 'package:document_organiser/boxes/boxes.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../database/save.dart';
import '../../provider/db_provider.dart';
import 'category_insider.dart';

class Categories extends StatefulWidget {
  // final bool isLoggedIn;
  bool isFromCategories;

  Categories({super.key, required this.isFromCategories});

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
    super.initState();

    isLogin();
    loadCountFromDatabase();

    // hideEmptyCategories();
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

      data = Save(name: "Contract", image: '');
      box = Boxes.getData();
      box.add(data);

      print(box.get("name"));

      prefs.setBool("isFirst", true);
    } else {
      if (prefs.getBool("isFirst")! == false) {
        var data = Save(name: "Invoice", image: '');
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
    // print("isHideEmptyCategories $isEmptyCategories");
  }

  int count = 0;
  loadCountFromDatabase() async {
    // open the database for count
    outerCountBox = await Hive.openBox("OuterCount");

    SharedPreferences imageLengthPref = await SharedPreferences.getInstance();
    print(
        "Added value in database : ${"Personal"} ::::: ${imageLengthPref.getInt(categoryList[0])}");

    print(categoryList[0]);
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
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.74,
              crossAxisSpacing: 8,
              mainAxisSpacing: 6,
            ),
            itemCount: box.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  widget.isFromCategories = true;

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryInsider(
                        categoryLabel: data[index].name,
                        isFromCategories: widget.isFromCategories,
                      ),
                    ),
                  );
                },
                child: Card(
                  color: Color(0xffF6F7F8),
                  child: Container(
                    color: Color(0xffF0F1F5),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Image.asset(
                            "assets/images/folder.png",
                            width: 80,
                            height: 80,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "My",
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                    height:
                                        4), // Add some spacing between "My" text and the existing widget
                                Text(
                                  "${data[index].name}",
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child:
                              /*IconButton(

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
                                          categoryList
                                              .remove(categoryList.last);

                                          Navigator.pop(context);
                                          print(
                                              "categoryList.last ${categoryList.length}");
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );

                              setState(() {});
                            },
                            icon: Icon(Icons.delete),
                          ),*/
                              PopupMenuButton<String>(
                            icon: Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 12.0, left: 14),
                              child: Image.asset(
                                'assets/images/more.png', // Replace with your image path
                                width: 24, // Set your desired width
                                height: 24, // Set your desired height
                              ),
                            ),
                            onSelected: (deleteCategory) {
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
                                          categoryList
                                              .remove(categoryList.last);

                                          Navigator.pop(context);
                                          print(
                                              "categoryList.last ${categoryList.length}");
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );

                              setState(() {});
                            },
                            itemBuilder: (BuildContext context) {
                              return <PopupMenuEntry<String>>[
                                PopupMenuItem<String>(
                                  value: 'deleteCategory',
                                  child: Text('Delete'),
                                ),
                              ];
                            },
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 12),
                            child: Text(
                                outerCountBox == null
                                    ? ""
                                    : outerCountBox.get(data[index].name) ==
                                                null ||
                                            outerCountBox
                                                    .get(data[index].name) ==
                                                0
                                        ? "0"
                                        : "${outerCountBox.get(data[index].name).toString()} ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12)),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      floatingActionButton: Container(
        height: 100,
        width: 100,
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,

          // shape: ,
          child: Image.asset("assets/images/add_a.png", height: 80,width: 80,),
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
          // label: Text("New Category"),
          // icon: Icon(Icons.add),
        ),
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
