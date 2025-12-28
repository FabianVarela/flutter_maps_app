import 'package:flutter_maps_bloc/common/google_api_key.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:rxdart/rxdart.dart';

class DragMapBloc with GoogleApiKey {
  final _markers = <MarkerId, Marker>{};

  final _isFirstTime = BehaviorSubject<bool>();

  final _markerList = BehaviorSubject<Map<MarkerId, Marker>>();

  final _dragMapData = BehaviorSubject<DragMapData>();

  Stream<bool> get isFirstTime => _isFirstTime.stream;

  Stream<Map<MarkerId, Marker>> get markerList => _markerList.stream;

  Stream<DragMapData> get dragMapData => _dragMapData.stream;

  void getInitialPosition(LatLng latLng, String idMarker) {
    _isFirstTime.sink.add(true);

    final markerId = MarkerId(idMarker);
    final marker = Marker(markerId: markerId, position: latLng);

    _markers[markerId] = marker;
    _markerList.sink.add(_markers);

    Future<dynamic>.delayed(
      const Duration(seconds: 3),
      () => _isFirstTime.sink.add(false),
    );
  }

  void dragMarker(LatLng latLng, String idMarker) {
    final markerId = MarkerId(idMarker);
    final marker = _markers[markerId];
    final updatedMarker = marker?.copyWith(positionParam: latLng);

    if (updatedMarker != null) {
      _markers[markerId] = updatedMarker;
      _markerList.sink.add(_markers);
    }
  }

  Future<void> getAddress(double lat, double lng) async {
    final geoCoding = GoogleMapsGeocoding(apiKey: mapsApiKey);
    final response = await geoCoding.searchByLocation(
      Location(lat: lat, lng: lng),
    );

    if (response.results.isNotEmpty) {
      final formattedAddress = response.results[0].formattedAddress;
      _dragMapData.sink.add(
        DragMapData(
          latitude: lat,
          longitude: lng,
          formattedAddress: formattedAddress,
        ),
      );
    }
  }

  void dispose() {
    _markerList.close();
    _isFirstTime.close();
    _dragMapData.close();
  }
}

class DragMapData {
  DragMapData({
    required this.latitude,
    required this.longitude,
    this.formattedAddress,
  });

  double latitude;
  double longitude;
  String? formattedAddress;
}
