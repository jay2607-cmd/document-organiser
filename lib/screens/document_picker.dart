import 'dart:io';

import 'package:document_organiser/screens/views/home_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';


class DocumentPicker extends StatefulWidget {


  const DocumentPicker({super.key
  });

  @override
  State<DocumentPicker> createState() => DocumentPickerState();
}

class DocumentPickerState extends State<DocumentPicker> {
  File? image;
  // FilePickerResult? pdfFile;
  // final picker = ImagePicker();
  String pdfFilePath = "";

  DateTime currentDate = DateTime.now();
  DateTime currentTime = DateTime.now();

  bool isImagePreview = false;
  bool isPDFPreview = false;

  Future getImageFromCamera() async {
    final pickerCameraImage =
        await ImagePicker().pickImage(source: ImageSource.camera);

    setState(() {
      if (pickerCameraImage != null) {
        image = File(pickerCameraImage.path);
        isImagePreview = true;
        isPDFPreview = false;

        print("pickerImageCamera.path ${image!.path}");
      } else {
        print("no image selected");
        isImagePreview = false;
      }
    });
  }

  Future getImageFromGallery() async {
    final pickerImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickerImage != null) {
        image = File(pickerImage.path);
        isImagePreview = true;
        isPDFPreview = false;

        print("pickerImageGallery.path ${image!.path}");
      } else {
        print("no image selected");
        isImagePreview = false;
      }
    });
  }

  void getPDF() async {
    FilePickerResult? resultFile = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

    if (resultFile != null) {
      PlatformFile file = resultFile.files.first;
      print(file.path);
      setState(() {
        pdfFilePath = file.path!;

        print("pdfFilePath $pdfFilePath");
      });
      isPDFPreview = true;
      isImagePreview = false;
    } else {
      pdfFilePath = "";
      print("no file selected");
      isPDFPreview = false;
    }

    // setState(() {
    //   pdfFile = resultFile;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Document Picker"),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                _willPopCallback();
              }),
          actions: [
            IconButton(
                onPressed: () async {
                  // showDialog(context: context, builder: (context) => DownloadingDialoag(image: image,isImagePreview: isImagePreview,isPDFPreview: isPDFPreview,pdfFilePath: pdfFilePath));

                  final directory = await getExternalStorageDirectory();

                  // print('Image Path : ${imagePath}');
                  // await imagePath.writeAsBytes(byteData.buffer.asUint8List());

                  if (isImagePreview) {
                    File imagePath =
                        await File('${directory!.path}/${DateTime.now()}.png')
                            .create();
                    await File(image!.path).copy(imagePath.path);
                    print("imagePath.path ${imagePath.path}");
                  } else if (isPDFPreview) {
                    final PDFPath =
                        await File('${directory!.path}/${DateTime.now()}.pdf')
                            .create();
                    await File(pdfFilePath).copy(PDFPath.path);
                    print("PDF.path ${PDFPath.path}");
                  }

                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => HomeScreen()));
                  // Navigator.pop(context);
                },
                icon: Icon(Icons.save))
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    image != null && isImagePreview
                        ? SingleChildScrollView(
                            child: Container(
                                height: 600,
                                width: 400,
                                child: Image.file(image!)))
                        : Text("No image selected"),

                    // pdfFile != null ? SfPdfViewer.file(FilePickerResult()) : Text("No File Selected") ,\

                    pdfFilePath != "" && isPDFPreview
                        ? SingleChildScrollView(
                            child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                                height: 600,
                                width: 400,
                                child: SfPdfViewer.file(File(pdfFilePath))),
                          ))
                        : Text("No pdf selected"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          getImageFromCamera();
                        },
                        child: Text("Camera")),
                    SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          getImageFromGallery();
                        },
                        child: Text("Gallery")),
                    SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          getPDF();
                        },
                        child: Text("PDF")),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _willPopCallback() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomeScreen()));
    return Future.value(true);
  }
}
