import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:las_app/core/network/api_client.dart';
import 'package:las_app/features/portfolio/model_portfolio.dart';

class PortfolioRepository {
  Future<RepayResult> withdraw(data) async {
    debugPrint('Data ::: ${data['amount']}');
    try {
      final token =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJtb2JpbGUiOiIrOTE5MDAwMDEwMDAwIiwidXNlcklkIjozMjA4LCJpYXQiOjE3NjMzODQwNjEsImV4cCI6MTc2MzM4NTg2MX0.XRbWDVq48YBbMEUFK-nAhnWQi6SQHyqjjs4Aq19q2y4';
      // final token = await FlutterSecureStorage().read(key: 'token');
      final response = await ApiClient().post(
        '/customer-portal/withDrawl',
        data: {'req_id': data['reqId'], "disbursement_amount": data['amount']},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'x-public-ip': '27.107.213.154',
            'Content-Type': 'application/json',
          },
        ),
      );
      return repayFromJson(response.data);
    } on DioException catch (e) {
      return repayFromJson(e.response?.data);
    } catch (e) {
      return repayFromJson({});
    }
  }

  Future<RepayResult> repayment(data) async {
    try {
      final token =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJtb2JpbGUiOiIrOTE5MDAwMDEwMDAwIiwidXNlcklkIjozMjA4LCJpYXQiOjE3NjMzODQwNjEsImV4cCI6MTc2MzM4NTg2MX0.XRbWDVq48YBbMEUFK-nAhnWQi6SQHyqjjs4Aq19q2y4';
      // final token = await FlutterSecureStorage().read(key: 'token');
      final response = await ApiClient().post(
        '/customer-portal/repayment',
        data: {'req_id': data['reqId']},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'x-public-ip': '27.107.213.154',
            'Content-Type': 'application/json',
          },
        ),
      );
      return repayFromJson(response.data);
    } on DioException catch (e) {
      return repayFromJson(e.response?.data);
    } catch (e) {
      return repayFromJson({});
    }
  }
}
