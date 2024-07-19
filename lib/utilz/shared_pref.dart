import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static late SharedPreferences _sharedPrefs;

  /// call this method from iniState() function of mainApp().
  static Future<SharedPreferences> init() async {
    _sharedPrefs = await SharedPreferences.getInstance();
    return _sharedPrefs;
  }

  ///sets
  static Future<bool> setString(String key, String value) async =>
      await _sharedPrefs.setString(key, value);

  ///gets
  static String getString(String key) => _sharedPrefs.getString(key) ?? "";

}
