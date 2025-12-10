import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:las_app/models/statement/client_statement_response.dart';
import 'package:las_app/models/statement/holding_statement_response.dart';
import 'package:path_provider/path_provider.dart';

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
  // 🔥 Convert Base64 → PDF → Save → Open
  // ---------------------------------------------
  Future<void> downloadPdf(String base64String, String fileName) async {
    final bytes = base64Decode(base64String);

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/$fileName-${DateTime.now().millisecondsSinceEpoch}");

    await file.writeAsBytes(bytes);

    print("📄 PDF Saved: ${file.path}");
  }
}
