import 'dart:io';

import 'package:document_organiser/screens/views/category_insider.dart';
import 'package:document_organiser/screens/views/home_screen.dart';
import 'package:document_organiser/screens/views/image_preview.dart';
import 'package:document_organiser/screens/views/pdf_preview.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class DocumentPicker extends StatefulWidget {
  String value = "";

  DocumentPicker(String this.value);

  DocumentPicker.nothing();

  @override
  State<DocumentPicker> createState() => DocumentPickerState(value: value);
}

class DocumentPickerState extends State<DocumentPicker> {
  var notesBox;

  TextEditingController answer = TextEditingController();

  final String value;

  DocumentPickerState({required this.value});

  final pdf = pw.Document();

  CategoryInsiderState categoryInsiderState = CategoryInsiderState();

  File? image;
  // FilePickerResult? pdfFile;
  // final picker = ImagePicker();
  String pdfFilePath = "";

  DateTime currentDate = DateTime.now();
  DateTime currentTime = DateTime.now();

  bool isImagePreview = false;
  bool isPDFPreview = false;

  late File file;
  String updatedImagePath = "";
  String updatedPdfPath = "";
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

  String subfolderPath = "";

  List<File> imageFiles = [];
  List<File> pdfFiles = [];

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
                if (isImagePreview) {
                  await createPDF();
                  await savePDF();
                  showInSnackBar("Image saved as a Document");
                  _willPopCallback();
                } else if (isPDFPreview) {
                  showInSnackBar("Already a Document File");
                } else {
                  showInSnackBar("No file Chosen");
                }
              },
              icon: Icon(Icons.picture_as_pdf_sharp),
            ),
            IconButton(
                onPressed: () async {
                  // showDialog(context: context, builder: (context) => DownloadingDialoag(image: image,isImagePreview: isImagePreview,isPDFPreview: isPDFPreview,pdfFilePath: pdfFilePath));

                  final directory = await getExternalStorageDirectory();

                  // print('Image Path : ${imagePath}');
                  // await imagePath.writeAsBytes(byteData.buffer.asUint8List());
                  File? imagePath;
                  if (isImagePreview) {
                    // moveFileToSubfolder(File(image!.path), value);

                    imagePath = await File(
                            '${directory!.path}/${DateTime.now().millisecondsSinceEpoch}.png')
                        .create();
                    await File(image!.path).copy(imagePath.path);
                    print("imagePath.path ${imagePath.path}");

                    // createSubfolder(value,imagePath.path);
                    subfolderPath =
                        await createSubfolder(value, imagePath.path);
                    await moveFileToSubfolder(imagePath.path);

                    notesBox = await Hive.openBox("Notes");
                    print("updatedImagePath ${updatedImagePath}");
                    if (answer.text.isNotEmpty) {
                      await notesBox.put(updatedImagePath, answer.text);
                      String data = notesBox.get(updatedImagePath);
                    } else {

                      print("Not added in database");
                    }
                  } else if (isPDFPreview) {
                    final PDFPath =
                        await File('${directory!.path}/${DateTime.now()}.pdf')
                            .create();
                    await File(pdfFilePath).copy(PDFPath.path);
                    print("PDF.path ${PDFPath.path}");

                    subfolderPath = await createSubfolder(value, PDFPath.path);

                    await moveFileToSubfolder(PDFPath.path);

                    notesBox = await Hive.openBox("Notes");
                    print("updatedImagePath ${updatedPdfPath}");
                    if (answer.text.isNotEmpty) {
                      await notesBox.put(updatedPdfPath, answer.text);
                      String data = notesBox.get(updatedPdfPath);
                    } else {

                      print("Not added in database");
                    }

                  }
                  if (isImagePreview || isPDFPreview) {
                    _willPopCallback();
                  } else {
                    showInSnackBar("Please select a file to save");
                  }
                  // Navigator.pop(context);
                },
                icon: Icon(Icons.save))
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      value,
                      style: TextStyle(fontSize: 30),
                    ),
                    image != null && isImagePreview
                        ? Column(
                            children: [
                              Container(
                                  height: 500,
                                  width: 400,
                                  child: Image.file(image!)),
                            ],
                          )
                        : Text("No image selected"),

                    // pdfFile != null ? SfPdfViewer.file(FilePickerResult()) : Text("No File Selected") ,\

                    pdfFilePath != "" && isPDFPreview
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                                height: 300,
                                width: 400,
                                child: SfPdfViewer.file(File(pdfFilePath))),
                          )
                        : Text("No pdf selected"),
                    buildTextField(answer),
                  ],
                ),
                /*Row(
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
                ),*/
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton: ExpandableFab(
          child: Icon(Icons.add),
          children: [
            FloatingActionButton(
              heroTag: null,
              child: const Icon(Icons.camera),
              onPressed: () {
                getImageFromCamera();
              },
            ),
            FloatingActionButton(
              heroTag: null,
              child: const Icon(Icons.photo),
              onPressed: () {
                getImageFromGallery();
              },
            ),
            FloatingActionButton(
              heroTag: null,
              child: const Icon(Icons.picture_as_pdf),
              onPressed: () {
                getPDF();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<String> createSubfolder(
      String subfolderName, String oldImagePath) async {
    // Get the external storage directory
    Directory? externalDir = await getExternalStorageDirectory();

    // Create the subfolder path
    String subfolderPath = '${externalDir?.path}/$subfolderName';

    // Check if the subfolder already exists
    if (!(await Directory(subfolderPath).exists())) {
      // Create the subfolder
      await Directory(subfolderPath).create(recursive: true);
      print("already exist");
    }
    print("subfolder created $subfolderPath");

    // Return the subfolder path
    return subfolderPath;
  }

  Future<void> moveFileToSubfolder(String oldImagePath) async {
    print("subfolderPath : $subfolderPath");

    // Get the file name
    String fileName = oldImagePath.split('/').last;
    print("filename moved ${fileName}");

    // Move the file to the subfolder

    await File(oldImagePath).rename('$subfolderPath/$fileName');

    print('oldImagePath ==>> $subfolderPath/$fileName');

    updatedImagePath = "$subfolderPath/$fileName";
    print("pdated e imag ep[ath : $updatedImagePath");

    updatedPdfPath = "$subfolderPath/$fileName";

  }

/*  Future<String> createSubfolder(String subfolderName) async {
    // Get the external storage directory
    Directory? externalDir = await getExternalStorageDirectory();

    // Create the subfolder path
    String subfolderPath = '${externalDir?.path}/$subfolderName';

    // Check if the subfolder already exists
    if (!(await Directory(subfolderPath).exists())) {
      // Create the subfolder
      await Directory(subfolderPath).create(recursive: true);
    }

    // Return the subfolder path
    return subfolderPath;
  }

  void moveFileToSubfolder(File file, String subfolderName) async {
    String subfolderPath = await createSubfolder(subfolderName);

    print(subfolderPath);

    // Get the file name
    String fileName = file.path.split('/').last;

    // Move the file to the subfolder
    await file.rename('$subfolderPath/$fileName');
  }*/

  Future<bool> _willPopCallback() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (builder) => HomeScreen()));
    return Future.value(true);
  }

  createPDF() async {
    final image2 = pw.MemoryImage(image!.readAsBytesSync());
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(child: pw.Image(image2));
        },
      ),
    );
  }

  savePDF() async {
    /*
    final directory = await getExternalStorageDirectory();

    final PDFPath =
        await File('${directory!.path}/${DateTime.now()}.pdf')
        .create();
    await File(pdfFilePath).copy(PDFPath.path);
    print("PDF.path ${PDFPath.path}");

    subfolderPath = await createSubfolder(value, PDFPath.path);

    moveFileToSubfolder(PDFPath.path);
    */

    try {
      final directory = await getExternalStorageDirectory();
      final PDFPath = await File(
          '${directory!.path}/${DateTime.now().millisecondsSinceEpoch}.pdf');
      print("PDFPAth : $PDFPath");
      await PDFPath.writeAsBytes(await pdf.save());

      print("$PDFPath PDFPath is here");

      subfolderPath = await createSubfolder(value, PDFPath.path);

      moveFileToSubfolder(PDFPath.path);
    } catch (e) {
      showInSnackBar(e.toString());
    }
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ));
  }

  TextField buildTextField(TextEditingController answer) {
    return TextField(
      maxLines: null,
      decoration: InputDecoration(
        border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(10)),
        hintText: 'Notes',
        // helperText: 'Keep it meaningful for future purposes',
        labelText: '${widget.value} Notes (Optional)',
        prefixIcon: const Icon(
          Icons.question_answer,
          color: Colors.blue,
        ),
      ),
      controller: answer,
    );
  }
}
