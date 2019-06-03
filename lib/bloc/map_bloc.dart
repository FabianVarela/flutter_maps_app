import 'package:flutter_maps_bloc/bloc/base_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapBloc implements BaseBloc {
  Map<MarkerId, Marker> _markers = {};

  /// Subjects or StreamControllers
  final _markerList = BehaviorSubject<Map<MarkerId, Marker>>();

  /// Observables
  Observable<Map<MarkerId, Marker>> get markerList => _markerList.stream;

  /// Functions
  void setOriginMarkers(double lat, double lng) {
    var markerId = MarkerId("Current location");
    var marker = Marker(
      markerId: markerId,
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(
        title: "Current location",
        snippet: "Current place",
      ),
    );

    _markers[markerId] = marker;
    _markerList.sink.add(_markers);
  }

  /// Override functions
  @override
  void dispose() {
    _markerList.close();
  }
}
