import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';

import 'base_bloc.dart';

class GeoPositionBloc implements BaseBloc {
  final geoLocator = Geolocator();
  var locationOptions = LocationOptions(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );

  /// Subjects or StreamControllers
  final _position = BehaviorSubject<Position>();

  /// Observables
  Observable<Position> get position => _position.stream;

  /// Functions
  void init() {
    geoLocator.getPositionStream(locationOptions).listen((position) {
      print("${position.latitude}, ${position.longitude}");
      _position.sink.add(position);
    });
  }

  /// Override functions
  @override
  void dispose() {
    _position.close();
  }
}
