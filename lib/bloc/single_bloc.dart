import 'package:flutter/foundation.dart';
import 'package:flutter_maps_app/common/preferences.dart';
import 'package:flutter_maps_app/common/utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';

class SingleBloc with Preferences {
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
    final mapMode = await getMapMode();
    try {
      final mapFileData = await Utils.getFileData('assets/$mapMode.json');
      _mapMode.sink.add(mapFileData);
    } catch (_) {
      _mapMode.sink.add('');
    }
  }

  Future<void> changeMapMode(String mode) async {
    await saveMapMode(mode);
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

final SingleBloc singleBloc = SingleBloc();
