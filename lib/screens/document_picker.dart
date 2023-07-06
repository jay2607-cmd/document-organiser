import 'dart:io';

import 'package:document_organiser/screens/views/category_insider.dart';
import 'package:document_organiser/screens/views/home_screen.dart';
import 'package:document_organiser/screens/views/image_preview.dart';
import 'package:document_organiser/screens/views/pdf_preview.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
              onPressed: () {
                if (isImagePreview) {
                  createPDF();
                  savePDF();
                }
                else {
                  print("Choose PNG file please");
                }
                _willPopCallback();
              },
              icon: Icon(Icons.picture_as_pdf_sharp),
            ),
            IconButton(
                onPressed: () async {
                  // showDialog(context: context, builder: (context) => DownloadingDialoag(image: image,isImagePreview: isImagePreview,isPDFPreview: isPDFPreview,pdfFilePath: pdfFilePath));

                  final directory = await getExternalStorageDirectory();

                  // print('Image Path : ${imagePath}');
                  // await imagePath.writeAsBytes(byteData.buffer.asUint8List());

                  if (isImagePreview) {
                    // moveFileToSubfolder(File(image!.path), value);

                    File imagePath =
                        await File('${directory!.path}/${DateTime.now()}.png')
                            .create();
                    await File(image!.path).copy(imagePath.path);
                    print("imagePath.path ${imagePath.path}");

                    // createSubfolder(value,imagePath.path);
                    subfolderPath =
                        await createSubfolder(value, imagePath.path);
                    moveFileToSubfolder(imagePath.path);
                  } else if (isPDFPreview) {
                    final PDFPath =
                        await File('${directory!.path}/${DateTime.now()}.pdf')
                            .create();
                    await File(pdfFilePath).copy(PDFPath.path);
                    print("PDF.path ${PDFPath.path}");

                    subfolderPath = await createSubfolder(value, PDFPath.path);

                    moveFileToSubfolder(PDFPath.path);
                  }

                  _willPopCallback();
                  // Navigator.pop(context);
                },
                icon: Icon(Icons.save))
          ],
        ),
        body: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 30),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16, top: 6, bottom: 6),
                  child: SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          color: Color(0xFFF6F7F8)),
                    ),
                  ),
                ),
                image != null && isImagePreview
                    ? SingleChildScrollView(
                        child: Container(
                            height: 600, width: 400, child: Image.file(image!)),
                      )
                    : Text("No image selected"),

                // pdfFile != null ? SfPdfViewer.file(FilePickerResult()) : Text("No File Selected") ,\

                pdfFilePath != "" && isPDFPreview
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            height: 600,
                            width: 400,
                            child: SfPdfViewer.file(File(pdfFilePath))),
                      )
                    : Text("No pdf selected"),
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
            Expanded(child: allImages()),
            Expanded(child: allPDFs())
          ],
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

  void moveFileToSubfolder(String oldImagePath) async {
    print("subfolderPath : $subfolderPath");

    // Get the file name
    String fileName = oldImagePath.split('/').last;
    print("filename moved ${fileName}");

    // Move the file to the subfolder

    await File(oldImagePath).rename('$subfolderPath/$fileName');
  }

  GridView allPDFs() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5 / 3,
        crossAxisSpacing: 20.0,
        mainAxisSpacing: 30.0,
      ),
      itemCount: pdfFiles.length,
      itemBuilder: (BuildContext context, int index) {
        file = pdfFiles[index];
        return GestureDetector(
          onTap: () {
            print("${index}");
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PdfPreview(
                          PdfPath: pdfFiles[index].path,
                        )));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Container(height: 250,width: 250,child: Image.file(file)),
              // Text(file.path),

              // child: Image.file(file),
              Container(
                height: 260,
                width: 250,
                child: SfPdfViewer.file(
                  File(file.path),
                ),
              ),
              Text(file.path.substring(70, 81)),
              Text(file.path.substring(81, 89)),

              // Text(file.path),
            ],
          ),
        );
      },
    );
  }

  GridView allImages() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5 / 3,
        crossAxisSpacing: 20.0,
        mainAxisSpacing: 30.0,
      ),
      itemCount: imageFiles.length,
      itemBuilder: (BuildContext context, int index) {
        file = imageFiles[index];
        return GestureDetector(
          onTap: () {
            print("${index}");
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ImagePreview(
                          filePath: imageFiles[index].path,
                          file: imageFiles[index],
                          imageFiles: imageFiles,
                          index: index,
                        )));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(height: 250, width: 250, child: Image.file(file)),
              // Text(file.path),
              Text(file.path.substring(70, 81)),
              Text(file.path.substring(81, 89)),

              SizedBox(
                height: 30,
              ),

              // child: Image.file(file),
              // Container(
              //   height: 260,
              //   width: 250,
              //   child: SfPdfViewer.file(
              //     File(file.path),
              //   ),
              // ),

              // Text(file.path),
            ],
          ),
        );
      },
    );
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
        context, MaterialPageRoute(builder: (context) => HomeScreen()));
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

    try{
      final directory = await getExternalStorageDirectory();
      final PDFPath = await File('${directory!.path}/${DateTime.now()}.pdf');

      await PDFPath.writeAsBytes(await pdf.save());

      print("$PDFPath PDFPath is here");

      subfolderPath = await createSubfolder(value, PDFPath.path);

      moveFileToSubfolder(PDFPath.path);

      showInSnackBar("Image saved as a Document");
    }

    catch(e){
      showInSnackBar(e.toString());
    }
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ));
  }

}
