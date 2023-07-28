import 'dart:io';

import 'package:document_organiser/screens/views/category_insider.dart';
import 'package:document_organiser/screens/views/home_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../provider/db_provider.dart';
import '../utils/constants.dart';

enum AppState { free, picked, cropped }

class DocumentPicker extends StatefulWidget {
  String value = "";
  final bool isFromCategories;

  DocumentPicker(String this.value, {required this.isFromCategories});

  @override
  State<DocumentPicker> createState() => DocumentPickerState(value: value);
}

class DocumentPickerState extends State<DocumentPicker> {
  bool isAdded = false;

  var notesBox;

  List<File> imageFiles = [];
  List<File> pdfFiles = [];

  late AppState state;
  File? image;

  TextEditingController answer = TextEditingController();

  final String value;

  DocumentPickerState({required this.value});

  final pdf = pw.Document();

  CategoryInsiderState categoryInsiderState = CategoryInsiderState();

  String pdfFilePath = "";

  DateTime currentDate = DateTime.now();
  DateTime currentTime = DateTime.now();

  bool isImagePreview = false;
  bool isPDFPreview = false;

  late File file;
  String updatedImagePath = "";
  String updatedPdfPath = "";
  bool isEmptyCategories = false;

  @override
  void initState() {
    super.initState();
    state = AppState.free;
    DbProvider().getEmptyCategories().then((value) {
      setState(() {
        isEmptyCategories = value;
      });
    });

    print("isEmptyCategories $isEmptyCategories");
  }

  Future getImageFromCamera() async {
    final pickerCameraImage =
        await ImagePicker().pickImage(source: ImageSource.camera);

    setState(() {
      if (pickerCameraImage != null) {
        image = File(pickerCameraImage.path);
        isImagePreview = true;
        state = AppState.picked;
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
        state = AppState.picked;
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: IconButton(
              icon: Image.asset(
                'assets/images/back.png',
                height: 24,
                width: 24,
              ),
              onPressed: () {
                _willPopCallback();
              },
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              "Doc Picker",
              style: kAppbarStyle,
            ),
          ),
          actions: [
            IconButton(
                onPressed: () async {
                  if (isImagePreview) {
                    await createPDF();
                    await savePDF();

                    isAdded = true;

                    var outerBox = await Hive.openBox("OuterCount");
                    // int count = outerBox  != null ? outerBox.get(widget.value) : isAdded = false;

                    int count = outerBox == null
                        ? 0
                        : outerBox.get(widget.value) == null
                            ? 0
                            : outerBox.get(widget.value);

                    if (isAdded) {
                      outerBox.put(widget.value, count + 1);
                    }

                    showInSnackBar("Image saved as a Document");
                    _willPopCallback();
                  } else if (isPDFPreview) {
                    showInSnackBar("Already a Document File");
                  } else {
                    showInSnackBar("No file Chosen");
                  }
                },
                icon: Image.asset(
                  "assets/images/pdf.png",
                  width: 28,
                  height: 28,
                )),
            IconButton(
                onPressed: () {
                  if (state == AppState.free) {
                    showInSnackBar("please select image file");
                  } else if (state == AppState.picked) {
                    _cropImage();
                  } else if (state == AppState.cropped) {
                    _cropImage();
                  }
                },
                icon: _buildButtonIcon()),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
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
                      final PDFPath = await File(
                              '${directory!.path}/${DateTime.now().millisecondsSinceEpoch}.pdf')
                          .create();
                      await File(pdfFilePath).copy(PDFPath.path);
                      print("PDF.path ${PDFPath.path}");

                      subfolderPath =
                          await createSubfolder(value, PDFPath.path);

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
                      isAdded = true;

                      var outerBox = await Hive.openBox("OuterCount");
                      // int count = outerBox  != null ? outerBox.get(widget.value) : isAdded = false;

                      int count = outerBox == null
                          ? 0
                          : outerBox.get(widget.value) == null
                              ? 0
                              : outerBox.get(widget.value);

                      if (isAdded) {
                        outerBox.put(widget.value, count + 1);
                      }

                      _willPopCallback();
                      showInSnackBar("Image Saved");
                    } else {
                      showInSnackBar("Please select a file to save");
                    }
                    // Navigator.pop(context);
                  },
                  icon: Image.asset(
                    "assets/images/save.png",
                    width: 28,
                    height: 28,
                  )),
            ),
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
                                  height: 600,
                                  width: 500,
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
          backgroundColor: Color(0xff4F6DDC),
          children: [
            FloatingActionButton(
              backgroundColor: Color(0xff4F6DDC),
              heroTag: null,
              child: const Icon(Icons.camera),
              onPressed: () {
                getImageFromCamera();
              },
            ),
            FloatingActionButton(
              backgroundColor: Color(0xff4F6DDC),
              heroTag: null,
              child: const Icon(Icons.photo),
              onPressed: () {
                getImageFromGallery();
              },
            ),
            FloatingActionButton(
              backgroundColor: Color(0xff4F6DDC),
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

  Widget _buildButtonIcon() {
    if (state == AppState.free) {
      return Image.asset(
        "assets/images/crop.png",
        width: 28,
        height: 28,
      );
    } else if (state == AppState.picked) {
      return Image.asset(
        "assets/images/crop.png",
        width: 28,
        height: 28,
      );
    } else if (state == AppState.cropped) {
      return Image.asset(
        "assets/images/crop.png",
        width: 28,
        height: 28,
      );
    } else {
      return Icon(
        Icons.disabled_by_default,
        color: Colors.black,
      );
    }
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
    if (widget.isFromCategories) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (builder) => CategoryInsider(
                  categoryLabel: widget.value, isFromCategories: false)));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (builder) => HomeScreen()));
    }

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

  Future _cropImage() async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );
    if (croppedFile != null) {
      image = convertCroppedFileToFile(croppedFile);
      setState(() {
        state = AppState.cropped;
      });
    }
  }

  File convertCroppedFileToFile(CroppedFile croppedFile) {
    if (croppedFile.path != null) {
      return File(croppedFile.path);
    } else {
      throw Exception(
          "CroppedFile is not valid or does not contain a valid path.");
    }
  }

  /*void _clearImage() {
    image = null;

    setState(() {

      state = AppState.free;
    });
  }*/
}
