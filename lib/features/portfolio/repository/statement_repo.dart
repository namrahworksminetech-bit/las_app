import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:las_app/models/statement/client_statement_response.dart';
import 'package:las_app/models/statement/holding_statement_response.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;

class StatementRepository {

  Future<ClientStatementResponse?> getClientStatement(String reqId) async {
    final body = {"req_id": reqId};


    final res = await http.post(
      Uri.parse("https://api-uat.valuenable.in/lamf/customer-portal/client-statement"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    return ClientStatementResponse.fromJson(jsonDecode(res.body));
  }

  Future<HoldingStatementResponse?> getHoldingStatement(String reqId) async {
    final body = {"req_id": reqId};

    final res = await http.post(
      Uri.parse("https://api-uat.valuenable.in/lamf/customer-portal/holding-statement"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    return HoldingStatementResponse.fromJson(jsonDecode(res.body));
  }


  // ---------------------------------------------
  Future<void> downloadPdf(String base64String, String fileName) async {
    final bytes = base64Decode(base64String);

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/$fileName");

    await file.writeAsBytes(bytes);

    print("📄 PDF Saved: ${file.path}");
  }


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
