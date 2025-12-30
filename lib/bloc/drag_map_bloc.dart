import 'package:flutter_maps_app/core/client/maps_client.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';

class DragMapBloc {
  DragMapBloc({required this.mapsClient});

  final MapsClient mapsClient;

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
    final positionParams = (lat: lat, lng: lng);
    final address = await mapsClient.getAddressFromPosition(positionParams);

    if (address != null) {
      _dragMapData.sink.add(
        DragMapData(latitude: lat, longitude: lng, formattedAddress: address),
      );
    }
  }

  void dispose() {
    _markerList.close();
    _isFirstTime.close();
    _dragMapData.close();
  }
}

final dragMapBloc = DragMapBloc(mapsClient: MapsClient());

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
