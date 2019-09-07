import 'package:flutter/services.dart' show rootBundle;

class Utils {
  static  Future<String> getFileData(String path) async =>
      await rootBundle.loadString(path);
}
