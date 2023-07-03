import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DownloadingDialoag extends StatefulWidget {
  final bool isImagePreview, isPDFPreview;
  final File? image;
  final String pdfFilePath;

  const DownloadingDialoag(
      {super.key,
      required this.isImagePreview,
      required this.isPDFPreview,
      required this.image,
      required this.pdfFilePath});

  @override
  State<DownloadingDialoag> createState() => _DownloadingDialoagState();
}

class _DownloadingDialoagState extends State<DownloadingDialoag> {
  @override
  Widget build(BuildContext context) {

    throw UnimplementedError();
  }
  /*Dio dio = Dio();
  double progress = 0.0;
  String url = "";
  DateTime currentDate = DateTime.now();
  DateTime currentTime = DateTime.now();

  @override
  void initState() {
    startDownloading();
    super.initState();
  }

  void startDownloading() async {
    String date = "${currentDate.day}-${currentDate.month}-${currentDate.year}";
    String time =
        "${currentTime.hour}:${currentTime.minute}:${currentTime.second}";
    if (widget.isImagePreview) {
      url = widget.image!.path;
    } else if (widget.isPDFPreview) {
      url = widget.pdfFilePath;
    }

    String filename = "$date$time";
    String path = await getFilePath(filename);

    await dio.download(
      url,
      path,
      onReceiveProgress: (receivedBytes, totalBytes) {
        setState(
          () {
            progress = receivedBytes / totalBytes;
          },
        );
        print(progress);
      },
      deleteOnError: true,
    ).then((_) {
      Navigator.pop(context);
    });
  }

  Future<String> getFilePath(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    return "${dir.path}/$filename";
  }

  @override
  Widget build(BuildContext context) {
    String downloadingProgress = (progress * 100).toInt().toString();

    return AlertDialog(
      backgroundColor: Colors.black,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator.adaptive(),
          const SizedBox(
            height: 20,
          ),
          Text(
            "Adding Document: $downloadingProgress",
            style: const TextStyle(color: Colors.white, fontSize: 17),
          )
        ],
      ),
    );
  }*/

}
