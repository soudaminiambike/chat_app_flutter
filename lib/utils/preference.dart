import 'package:shared_preferences/shared_preferences.dart';

class Preference {

  static Preference _instance;

  static SharedPreferences preferences;

  static Future<Preference> getInstance() async {
    if (_instance == null) {
      _instance = Preference();
    }
    if (preferences == null) {
      preferences = await SharedPreferences.getInstance();
    }
    return _instance;
  }
}