import 'package:dio/dio.dart';
import '../utils/constants.dart';

class ApiService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: Constants.baseUrl,
      headers: {
        'Accept': 'application/json',
      },
    ),
  );
}