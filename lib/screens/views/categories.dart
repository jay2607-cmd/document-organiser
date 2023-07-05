import 'package:document_organiser/boxes/boxes.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../database/save.dart';
import '../document_picker.dart';
import '../reusable_grid_view.dart';

class Categories extends StatefulWidget {
  // final bool isLoggedIn;
  const Categories({super.key
      // required this.isLoggedIn,
      });

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  TextEditingController categoryController = TextEditingController();

/*  String category1 = "i";
  String category2 = "";
  String category3 = "";
  String category4 = "";
  String category5 = "";
  String category6 = "";
  String category7 = "";
  String category8 = "";
  String category9 = "";
  String category10 = "";
  String category11 = "";
  String category12 = "";
  String category13 = "";
  String category14 = "";

  @override
  void initState() {
    isLogin();
    super.initState();
  }

  void isLogin() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString("Category1", "Invoice");
    sp.setString("Category2", "Personal");
    sp.setString("Category3", "Bank");
    sp.setString("Category4", "Medical");
    sp.setString("Category5", "Business");
    sp.setString("Category6", "Ticket");
    sp.setString("Category7", "Water");
    sp.setString("Category8", "Electricity");
    sp.setString("Category9", "Gas");
    sp.setString("Category10", "Book");
    sp.setString("Category11", "School");
    sp.setString("Category12", "Product");
    sp.setString("Category13", "Contract");
    sp.setString("Category14", "Add");

    category1 = sp.getString("Category1")!;
    category2 = sp.getString("Category2")!;
    category3 = sp.getString("Category3")!;
    category4 = sp.getString("Category4")!;
    category5 = sp.getString("Category5")!;
    category6 = sp.getString("Category6")!;
    category7 = sp.getString("Category7")!;
    category8 = sp.getString("Category8")!;
    category9 = sp.getString("Category9")!;
    category10 = sp.getString("Category10")!;
    category11 = sp.getString("Category11")!;
    category12 = sp.getString("Category12")!;
    category13 = sp.getString("Category13")!;
    category14 = sp.getString("Category14")!;

    setState(() {

    });
  }*/

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

      data = Save(name: "Ticket ", image: "");
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

        data = Save(name: "Ticket ", image: "");
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

   List dropDownList = [];
  @override
  Widget build(BuildContext context) {
    /*
      children: <Widget>[
        ReusableGridView(
          className: DocumentPicker(),
          label1: category1,
          imgPath: Icon(Icons.file_copy),
        ),
        ReusableGridView(
          className: DocumentPicker(),
          label1: category2,
          imgPath: Icon(Icons.personal_injury),
        ),
        ReusableGridView(
          className: DocumentPicker(),
          label1: category3,
          imgPath: Icon(Icons.food_bank),
        ),
        ReusableGridView(
          className: DocumentPicker(),
          label1: category4,
          imgPath: Icon(Icons.medical_information),
        ),
        ReusableGridView(
          className: DocumentPicker(),
          label1: category5,
          imgPath: Icon(Icons.add_card),
        ),
        ReusableGridView(
          className: DocumentPicker(),
          label1: category6,
          imgPath: Icon(Icons.airplane_ticket_outlined),
        ),
        ReusableGridView(
          className: DocumentPicker(),
          label1: category7,
          imgPath: Icon(Icons.water_drop),
        ),
        ReusableGridView(
          className: DocumentPicker(),
          label1: category8,
          imgPath: Icon(Icons.electric_bolt),
        ),
        ReusableGridView(
          className: DocumentPicker(),
          label1: category9,
          imgPath: Icon(Icons.local_fire_department_sharp),
        ),
        ReusableGridView(
          className: DocumentPicker(),
          label1: category10,
          imgPath: Icon(Icons.book),
        ),
        ReusableGridView(
          className: DocumentPicker(),
          label1: category11,
          imgPath: Icon(Icons.school),
        ),
        ReusableGridView(
          className: DocumentPicker(),
          label1: category12,
          imgPath: Icon(Icons.shopping_bag_sharp),
        ),
        ReusableGridView(
          className: DocumentPicker(),
          label1: category13,
          imgPath: Icon(Icons.currency_exchange_rounded),
        ),
        ReusableGridView(
          className: DocumentPicker(),
          label1: category14,
          imgPath: Icon(Icons.add),
        ),
      ],
      */
    return Scaffold(
      body: ValueListenableBuilder<Box<Save>>(
        valueListenable: Boxes.getData().listenable(),
        builder: (context, box, _) {
          var data = box.values.toList().cast<Save>();
          print("data length ${data.length}");
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
                          builder: (context) =>
                              DocumentPicker(data[index].name)));
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        20), // Set the desired border radiusSet the desired background color
                  ),
                  child: Card(
                    // elevation: 0,

                    color: Color(0xffF6F7F8),
                    child: Container(
                      color: Colors.blue.shade200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(data[index].name,
                                  style: const TextStyle(fontSize: 13)),
                              // SizedBox(
                              //   height: 4,
                              // ),
                              // Text(
                              //     "Date  :  ${data[reversedIndex].date.toString()}",
                              //     style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
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
                      }
                      box.add(data);

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

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ));
  }
}
