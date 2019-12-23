import 'package:flutter_maps_bloc/bloc/base_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';

class GeoPositionBloc implements BaseBloc {
  final Geolocator geoLocator = Geolocator();
  final LocationOptions locationOptions = LocationOptions(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );

  /// Subjects or StreamControllers
  final BehaviorSubject<Position> _position = BehaviorSubject<Position>();

  /// Observables
  Observable<Position> get position => _position.stream;

  /// Functions
  void init() {
    geoLocator.getPositionStream(locationOptions).listen((Position position) {
      print('${position.latitude}, ${position.longitude}');
      _position.sink.add(position);
    });
  }

  /// Override functions
  @override
  void dispose() {
    _position.close();
  }
}
