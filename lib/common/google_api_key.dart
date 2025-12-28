import 'package:flutter/foundation.dart';

mixin GoogleApiKey {
  String get mapsApiKey {
    return defaultTargetPlatform == .android
        ? const String.fromEnvironment('GOOGLE_MAP_API_KEY_ANDROID')
        : const String.fromEnvironment('GOOGLE_MAP_API_KEY_IOS');
  }
}
