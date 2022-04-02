import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late Uint8List _imageFile;

  ScreenshotController screenshotController = ScreenshotController();
  TextEditingController textEditingController = TextEditingController();

  String text_to_add = "";
  late PdfBitmap image;
  void _takeScreenshot(Uint8List image) {
    setState(() {
      _imageFile = image;
    });
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });

    print(_counter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Screenshot(
              controller: screenshotController,
              child: Column(
                children: [
                  const Text(
                    'You have pushed the button this many times:',
                  ),
                  Text(
                    '$_counter',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ],
              ),
            ),
            TextField(
                controller: textEditingController,
                onChanged: (value) {
                  setState(() {
                    text_to_add = value;
                  });
                }),
            ElevatedButton(
              child: Text(
                'Capture Above Widget',
              ),
              onPressed: () {
                screenshotController
                    .capture(delay: Duration(milliseconds: 10))
                    .then((capturedImage) async {
                  print(capturedImage);

                  setState(() {
                    _imageFile = capturedImage!;
                    image = PdfBitmap(_imageFile);
                  });

                  final PdfDocument document = PdfDocument();

                  document.pages
                      .add()
                      .graphics
                      .drawImage(image, const Rect.fromLTWH(0, 0, 500, 200));

                  document.pages.add().graphics.drawString(
                      text_to_add, PdfStandardFont(PdfFontFamily.helvetica, 12),
                      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
                      bounds: const Rect.fromLTWH(0, 0, 150, 20));

                  var status = await Permission.storage.status;
                  if (!status.isGranted) {
                    await Permission.storage.request();
                  }
                  Directory? tempDir =
                      await DownloadsPathProvider.downloadsDirectory;
                  String tempPath = tempDir!.path;
                  print(tempPath);

                  File('$tempPath/ImageToPDF.pdf')
                      .writeAsBytes(document.save());
                  document.dispose();
                }).catchError((onError) {
                  print(onError);
                });
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
