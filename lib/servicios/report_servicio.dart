import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/report_model.dart';
import 'servicios_api.dart';

class ReportService {
  final ApiService _apiService = ApiService();

  Future<List<ReportModel>> getReports() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('token');

    Response response = await _apiService.dio.get(
      '/reports',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    List data = response.data;

    return data.map((e) => ReportModel.fromJson(e)).toList();
  }

  Future<bool> updateReport({
    required int id,
    required String title,
    required String description,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String? token = prefs.getString('token');

      await _apiService.dio.put(
        '/reports/$id',

        data: {'title': title, 'description': description},

        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteReport(int id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String? token = prefs.getString('token');

      await _apiService.dio.delete(
        '/reports/$id',

        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return true;
    } catch (e) {
      return false;
    }
  }
}
