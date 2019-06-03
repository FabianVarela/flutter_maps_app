import 'dart:io';

mixin GoogleApiKey {
  String getApiKey() {
    return Platform.isAndroid
        ? ""
        : "";
  }
}
