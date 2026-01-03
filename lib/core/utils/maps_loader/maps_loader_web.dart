import 'dart:async';
import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart';

class MapsLoader {
  static Future<void> loadGoogleMapsScript(String apiKey) async {
    if (_isScriptLoaded()) return;

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/js',
      {'key': apiKey, 'libraries': 'places', 'loading': 'async'},
    );

    final completer = Completer<void>();
    final script = document.createElement('script') as HTMLScriptElement
      ..src = uri.toString()
      ..async = true
      ..defer = true
      ..onload = (Event event) {
        if (kDebugMode) print('Google Maps API loaded successfully');
        completer.complete();
      }.toJS
      ..onerror = (Event event) {
        if (kDebugMode) print('Error loading Google Maps API');
        completer.completeError('Failed to load Google Maps');
      }.toJS;

    document.head?.appendChild(script);
    return completer.future;
  }

  static bool _isScriptLoaded() {
    return document.querySelector('script[src*="maps.googleapis.com"]') != null;
  }
}
