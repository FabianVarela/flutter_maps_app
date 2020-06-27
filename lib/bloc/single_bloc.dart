import 'package:flutter_maps_bloc/bloc/base_bloc.dart';
import 'package:flutter_maps_bloc/common/preferences.dart';
import 'package:flutter_maps_bloc/common/utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';

class SingleBloc with Preferences implements BaseBloc {
  final Geolocator geoLocator = Geolocator();
  final LocationOptions locationOptions = LocationOptions(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );

  /// Subjects or StreamControllers
  final BehaviorSubject<Position> _position = BehaviorSubject<Position>();
  final BehaviorSubject<String> _mapMode = BehaviorSubject<String>();

  /// Observables
  Stream<Position> get position => _position.stream;

  Stream<String> get mapMode => _mapMode.stream;

  /// Functions
  void setPosition() {
    geoLocator.getPositionStream(locationOptions).listen((Position position) {
      print('${position.latitude}, ${position.longitude}');
      _position.sink.add(position);
    });
  }

  void init() async {
    final String mapMode = await getMapMode();

    try {
      final String mapFileData =
      await Utils.getFileData('assets/$mapMode.json');
      _mapMode.sink.add(mapFileData);
    } catch (_) {
      _mapMode.sink.add('');
    }
  }

  void changeMapMode(String mode) async {
    await saveMapMode(mode);
    init();
  }

  @override
  void dispose() {
    _position.close();
    _mapMode.close();
  }
}

final SingleBloc singleBloc = SingleBloc();
