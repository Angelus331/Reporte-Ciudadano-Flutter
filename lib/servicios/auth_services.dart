import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'servicios_api.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<bool> login(String email, String password) async {
    try {
      Response response = await _apiService.dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      String token = response.data['token'];

      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString('token', token);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      await _apiService.dio.post(
        '/register',

        data: {'name': name, 'email': email, 'password': password},
      );

      return true;
    } catch (e) {
      return false;
    }
  }
}