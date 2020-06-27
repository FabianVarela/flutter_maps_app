import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';

mixin GoogleApiKey {
  String getApiKey() {
    final DotEnv dotEnv = DotEnv();

    return Platform.isAndroid
        ? dotEnv.env['GOOGLE_MAP_API_KEY_ANDROID']
        : dotEnv.env['GOOGLE_MAP_API_KEY_IOS'];
  }
}
