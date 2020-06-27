import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Utils {
  static  Future<String> getFileData(String path) async =>
      await rootBundle.loadString(path);

  static List<LatLng> decodePolyLine(String encoded) {
    final List<LatLng> poly = List<LatLng>();
    final int len = encoded.length;

    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final int dLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dLat;
      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final int dLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dLng;

      final LatLng p = LatLng(lat.toDouble() / 1E5, lng.toDouble() / 1E5);
      poly.add(p);
    }

    return poly;
  }
}
