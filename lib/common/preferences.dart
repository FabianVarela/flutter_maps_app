import 'package:shared_preferences/shared_preferences.dart';

mixin Preferences {
  SharedPreferences _sharedPreferences;

  /// Get the current map mode
  Future<String> getMapMode() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    return _sharedPreferences.getString("mapMode");
  }

  /// Save the current map mode
  Future saveMapMode(String mapModel) async {
    _sharedPreferences = await SharedPreferences.getInstance();
    await _sharedPreferences.setString("mapMode", mapModel);
  }
}
