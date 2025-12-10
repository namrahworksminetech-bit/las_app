import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:las_app/core/app_state_provider.dart';
import 'package:las_app/core/network/api_client.dart';
import 'package:las_app/features/portfolio/model_portfolio.dart';

class PortfolioRepository {
  final AppStateProvider _appState = GetIt.I<AppStateProvider>();

  Future<RepayResult> withdraw(data) async {
    debugPrint('Data ::: ${data['amount']}');
    try {

      final token = _appState.token;

      if (token == null || token.isEmpty) {
        throw Exception("Missing auth token");
      }
final reqId =_appState.reqId;
  
      final response = await ApiClient().post(
        '/customer-portal/withDrawl',
        data: {
          'req_id': reqId,
          "disbursement_amount": data['amount']
        },
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
   
      final token = _appState.token;
final reqId =_appState.reqId;
      if (token == null || token.isEmpty) {
        throw Exception("Missing auth token");
      }


      final response = await ApiClient().post(
        '/customer-portal/repayment',
        data: {'req_id':reqId},
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
