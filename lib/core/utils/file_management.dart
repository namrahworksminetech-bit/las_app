import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

class PdfFileConverter{

  static Future<bool> createAndOpenPdf(String base64String, String fileName) async {
    try {
      Uint8List pdfBytes = base64Decode(base64String);

      if (kIsWeb) {
        final blob = html.Blob([pdfBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..target = '_blank'
          ..download = '$fileName.pdf';
        anchor.click();
        html.Url.revokeObjectUrl(url);
        return Future.value(true);
      } else {
        var appStorage = await getApplicationDocumentsDirectory();
        String filePath = '${appStorage.path}/$fileName.pdf';

        File pdfFile = File(filePath);
        await pdfFile.writeAsBytes(pdfBytes);

        print(pdfFile.path);
        var result = await OpenFile.open(pdfFile.path);
        if(result.type == ResultType.done){
          return Future.value(true);
        }else{
          return Future.value(false);
        }
      }
    } catch (e) {
      print('Error creating or opening PDF: $e');
      return Future.value(false);
    }
  }

}