import 'package:flutter/material.dart';

class ReusableGridView extends StatelessWidget {
  const ReusableGridView({
    super.key,
    required this.className,
    required this.label1,
    required this.imgPath,
  });

  final Widget className;
  final String? label1;
  final Widget imgPath;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => className));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        color: Colors.blue.shade200
        ),
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
          top: 10,
          bottom: 10,
        ),
        child: Stack(
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              // mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child:  imgPath,

                  ),

              ],
            ),
            SizedBox.shrink(),
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // alignment: Alignment.center,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(label1!),

                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
