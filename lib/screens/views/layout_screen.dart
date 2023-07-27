import 'package:document_organiser/screens/views/bookmark_screen.dart';
import 'package:document_organiser/screens/views/home_screen.dart';
import 'package:document_organiser/settings/settings_screen.dart';
import 'package:flutter/material.dart';

class LayoutScreen extends StatefulWidget {
  const LayoutScreen({super.key});

  @override
  State<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: /*Column(
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HomeScreen()));
                },
                child: Text("Add Documents")),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SettingScreen()));
                },
                child: Text("Docs Settings ")),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => BookmarkScreen()));
                },
                child: Text("Bookmarked Docs")),
          ],
        ),*/
              Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Container(
          height: 273.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Color(0xffF0F1F2),
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Image.asset(
                        "assets/images/appicon_small.png",
                        height: 135,
                        width: 135,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 13.0, top: 28),
                    child: Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        "assets/images/App Name.png",
                        height: 100,
                        width: 195,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: EdgeInsets.only(top: 10, bottom: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            children: [
                              Image.asset("assets/images/info.png",
                                  height: 38, width: 33, fit: BoxFit.contain),
                              SizedBox(
                                height: 5,
                              ),
                              Image.asset("assets/images/ads.png",
                                  height: 38, width: 33, fit: BoxFit.contain),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              CustomDivider(),
              GridView.count(
                // childAspectRatio: 4 / 3,
                shrinkWrap: true,
                primary: false,
                padding: const EdgeInsets.only(left: 18, top: 15, right: 18),
                crossAxisSpacing: 12,
                mainAxisSpacing: 0,
                crossAxisCount: 3,
                children: <Widget>[
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeScreen()));
                      },
                      child: Image.asset("assets/images/btn1.png")),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SettingScreen()));
                      },
                      child: Image.asset("assets/images/btn2.png")),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BookmarkScreen()));
                      },
                      child: Image.asset("assets/images/btn3.png")),
                ],
              ),
            ],
          ),
        ),
      )),
    );
  }
}

class CustomDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Container(
        width: double.infinity,
        height: 2,
        color: Color(0xFFFFFFFF),
      ),
    );
  }
}
