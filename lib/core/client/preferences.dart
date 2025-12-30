import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  Preferences({required this.preferences});

  final SharedPreferences preferences;

  String? getMapMode() => preferences.getString('mapMode');

  Future<void> saveMapMode(String mapMode) async {
    await preferences.setString('mapMode', mapMode);
  }
}
