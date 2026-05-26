import 'package:shared_preferences/shared_preferences.dart';

class Storage {

  static Future<String?> getToken() async {

    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    return prefs.getString('token');
  }
}