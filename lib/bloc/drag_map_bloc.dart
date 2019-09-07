import 'package:flutter_maps_bloc/bloc/base_bloc.dart';
import 'package:flutter_maps_bloc/common/google_api_key.dart';
import 'package:flutter_maps_bloc/common/preferences.dart';
import 'package:flutter_maps_bloc/common/utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:rxdart/rxdart.dart';

class DragMapBloc with GoogleApiKey, Preferences implements BaseBloc {
  Map<MarkerId, Marker> _markers = {};

  /// Subjects or StreamControllers
  final _isFirstTime = BehaviorSubject<bool>();
  final _markerList = BehaviorSubject<Map<MarkerId, Marker>>();
  final _mapMode = BehaviorSubject<String>();
  final _dragMapData = BehaviorSubject<DragMapData>();

  /// Observables
  Observable<bool> get isFirstTime => _isFirstTime.stream;

  Observable<Map<MarkerId, Marker>> get markerList => _markerList.stream;

  Observable<String> get mapMode => _mapMode.stream;

  Observable<DragMapData> get dragMapData => _dragMapData.stream;

  void init() async {
    final mapMode = await getMapMode();

    try {
      final mapFileData = await Utils.getFileData('assets/$mapMode.json');
      _mapMode.sink.add(mapFileData);
    } catch (_) {
      _mapMode.sink.add('');
    }
  }

  void getInitialPosition(LatLng latLng, String idMarker) {
    _isFirstTime.sink.add(true);

    MarkerId markerId = MarkerId(idMarker);
    LatLng position = latLng;

    Marker marker = Marker(
      markerId: markerId,
      position: position,
      draggable: false,
    );

    _markers[markerId] = marker;
    _markerList.sink.add(_markers);

    Future.delayed(Duration(seconds: 3), () => _isFirstTime.sink.add(false));
  }

  void dragMarker(LatLng latLng, String idMarker) {
    MarkerId markerId = MarkerId(idMarker);
    Marker marker = _markers[markerId];
    Marker updatedMarker = marker.copyWith(positionParam: latLng);

    _markers[markerId] = updatedMarker;
    _markerList.sink.add(_markers);
  }

  void getAddress(double lat, double lng) async {
    final geoCoding = GoogleMapsGeocoding(apiKey: getApiKey());
    final response = await geoCoding.searchByLocation(Location(lat, lng));

    if (response.results.length > 0) {
      var formattedAddress = response.results[0].formattedAddress;
      _dragMapData.sink.add(DragMapData(lat, lng, formattedAddress));

      print(formattedAddress);
    }
  }

  @override
  void dispose() {
    _markerList.close();
    _isFirstTime.close();
    _mapMode.close();
    _dragMapData.close();
  }
}

class DragMapData {
  double latitude;
  double longitude;
  String formattedAddress;

  DragMapData(this.latitude, this.longitude, this.formattedAddress);
}
