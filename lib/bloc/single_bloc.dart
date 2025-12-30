import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_maps_app/core/client/preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SingleBloc {
  SingleBloc({required this.preferences});

  final Preferences preferences;

  static const _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );

  final _position = BehaviorSubject<Position>();
  final _mapMode = BehaviorSubject<String>();

  Stream<Position> get position => _position.stream;

  Stream<String> get mapMode => _mapMode.stream;

  Future<void> setPosition() async {
    try {
      await _setupPermissions();

      Geolocator.getPositionStream(locationSettings: _locationSettings).listen((
        position,
      ) {
        if (kDebugMode) print('${position.latitude}, ${position.longitude}');
        _position.sink.add(position);
      });
    } on Exception catch (error) {
      _position.sink.addError(error);
    }
  }

  Future<void> init() async {
    final mapMode = preferences.getMapMode();
    if (mapMode == null) return;

    try {
      final mapFileData = await rootBundle.loadString('assets/$mapMode.json');
      _mapMode.sink.add(mapFileData);
    } catch (_) {
      _mapMode.sink.add('');
    }
  }

  Future<void> changeMapMode(String mode) async {
    await preferences.saveMapMode(mode);
    await init();
  }

  Future<void> _setupPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }
  }

  void dispose() {
    _position.close();
    _mapMode.close();
  }
}

late SingleBloc singleBloc;

Future<void> initSingleBloc() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  singleBloc = SingleBloc(
    preferences: Preferences(preferences: sharedPreferences),
  );
}
