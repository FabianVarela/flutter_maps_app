import 'package:shared_preferences/shared_preferences.dart';

mixin Preferences {
  Future<String?> getMapMode() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('mapMode');
  }

  Future<void> saveMapMode(String mapModel) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString('mapMode', mapModel);
  }
}
