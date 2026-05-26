import 'package:dio/dio.dart';

import '../models/category_model.dart';
import 'servicios_api.dart';

class CategoryService {
  final ApiService _apiService = ApiService();

  Future<List<CategoryModel>> getCategories(String token) async {
    Response response = await _apiService.dio.get(
      '/categories',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    List data = response.data;

    return data.map((e) => CategoryModel.fromJson(e)).toList();
  }
}
