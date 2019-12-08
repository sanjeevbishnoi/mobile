//import 'dart:async';
//import 'dart:io';
//import 'dart:typed_data';
//import 'dart:ui' as ui;
//import 'package:flutter/material.dart';
//import 'package:flutter/rendering.dart';
//import 'package:flutter/services.dart';
//import 'package:path_provider/path_provider.dart';
//import 'package:pdf/pdf.dart';
//import 'package:pdf/widgets.dart' as pdf;
//import 'package:printing/printing.dart';
//import 'document.dart';
//import 'viewer.dart';
//
//class MyApp extends StatefulWidget {
//  @override
//  MyAppState createState() {
//    return MyAppState();
//  }
//}
//
//class MyAppState extends State<MyApp> {
//  final GlobalKey<State<StatefulWidget>> shareWidget = GlobalKey();
//  final GlobalKey<State<StatefulWidget>> previewContainer = GlobalKey();
//
//  Future<void> _printPdfA4() async {
//    print('Print ...');
//    await Printing.layoutPdf(
//        onLayout: (PdfPageFormat format) async =>
//            (await generateDocumentA4(format)).save());
//  }
//
//  Future<void> _printPdfA5() async {
//    print('Print ...');
//    await Printing.layoutPdf(
//        onLayout: (PdfPageFormat format) async =>
//            (await generateDocumentA5(format)).save());
//  }
//
//  Future<void> _saveAsFile() async {
//    final Directory appDocDir = await getApplicationDocumentsDirectory();
//    final String appDocPath = appDocDir.path;
//    final File file = File(appDocPath + '/' + 'document.pdf');
//    print('Save as file ${file.path} ...');
//    await file
//        .writeAsBytes((await generateDocumentA5(PdfPageFormat.a4)).save());
//    Navigator.push<dynamic>(
//      context,
//      MaterialPageRoute<dynamic>(
//          builder: (BuildContext context) => PdfViewer(file: file)),
//    );
//  }
//
//  Future<void> _sharePdf() async {
//    print('Share ...');
//    final pdf.Document document = await generateDocumentA5(PdfPageFormat.a4);
//
//    // Calculate the widget center for iPad sharing popup position
//    final RenderBox referenceBox =
//        shareWidget.currentContext.findRenderObject();
//    final Offset topLeft =
//        referenceBox.localToGlobal(referenceBox.paintBounds.topLeft);
//    final Offset bottomRight =
//        referenceBox.localToGlobal(referenceBox.paintBounds.bottomRight);
//    final Rect bounds = Rect.fromPoints(topLeft, bottomRight);
//
//    await Printing.sharePdf(
//        bytes: document.save(), filename: 'my-résumé.pdf', bounds: bounds);
//  }
//
//  Future<void> _printScreen() async {
//    final RenderRepaintBoundary boundary =
//        previewContainer.currentContext.findRenderObject();
//    final ui.Image im = await boundary.toImage();
//    final ByteData bytes =
//        await im.toByteData(format: ui.ImageByteFormat.rawRgba);
//    print('Print Screen ${im.width}x${im.height} ...');
//
//    Printing.layoutPdf(onLayout: (PdfPageFormat format) {
//      final pdf.Document document = PdfDoc();
//
//      final PdfImage image = PdfImage(document.document,
//          image: bytes.buffer.asUint8List(),
//          width: im.width,
//          height: im.height);
//
//      document.addPage(pdf.Page(
//          pageFormat: format,
//          build: (pdf.Context context) {
//            return pdf.Center(
//              child: pdf.Expanded(
//                child: pdf.Image(image),
//              ),
//            ); // Center
//          })); // Page
//
//      return document.save();
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return RepaintBoundary(
//        key: previewContainer,
//        child: Scaffold(
//          appBar: AppBar(
//            title: const Text('Pdf Printing Example'),
//          ),
//          body: Center(
//            child: Column(
//              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//              children: <Widget>[
//                RaisedButton(
//                    child: const Text('Print A4'), onPressed: _printPdfA4),
//                RaisedButton(
//                    child: const Text('Print A5'), onPressed: _printPdfA5),
//                RaisedButton(
//                    key: shareWidget,
//                    child: const Text('Share Document'),
//                    onPressed: _sharePdf),
//                RaisedButton(
//                    child: const Text('Print Screenshot'),
//                    onPressed: _printScreen),
//                RaisedButton(
//                    child: const Text('Save to file'), onPressed: _saveAsFile),
//              ],
//            ),
//          ),
//        ));
//  }
//}
