import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Utils {
  static Future<String> getFileData(String path) async =>
      rootBundle.loadString(path);

  static List<LatLng> decodePolyLine(String encoded) {
    final poly = <LatLng>[];
    final len = encoded.length;

    var index = 0;
    var lat = 0;
    var lng = 0;

    while (index < len) {
      int b;
      var shift = 0;
      var result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final dLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dLat;
      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final dLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dLng;

      final p = LatLng(lat.toDouble() / 1E5, lng.toDouble() / 1E5);
      poly.add(p);
    }

    return poly;
  }
}
