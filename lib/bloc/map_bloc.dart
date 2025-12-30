import 'dart:ui';

import 'package:flutter_maps_app/core/client/maps_client.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/directions.dart' as ws;
import 'package:rxdart/rxdart.dart';

class MapBloc {
  MapBloc({required this.mapsClient});

  final MapsClient mapsClient;

  final _markers = <MarkerId, Marker>{};
  final _polyLines = <PolylineId, Polyline>{};

  final _markerList = BehaviorSubject<Map<MarkerId, Marker>>();
  final _polylineList = BehaviorSubject<Map<PolylineId, Polyline>>();
  final _routeData = BehaviorSubject<RouteData?>();

  Stream<Map<MarkerId, Marker>> get markerList => _markerList.stream;

  Stream<Map<PolylineId, Polyline>> get polylineList => _polylineList.stream;

  Stream<RouteData?> get routeData => _routeData.stream;

  void setOriginMarkers(double lat, double lng) {
    const markerId = MarkerId('Current location');
    final marker = Marker(
      markerId: markerId,
      position: LatLng(lat, lng),
      infoWindow: const InfoWindow(
        title: 'Current location',
        snippet: 'Current place',
      ),
    );

    _markers[markerId] = marker;
    _markerList.sink.add(_markers);
  }

  void setDestinationMarker(double lat, double lng) {
    const markerId = MarkerId('Destination location');
    final destinationMarker = Marker(
      markerId: markerId,
      position: LatLng(lat, lng),
      infoWindow: const InfoWindow(
        title: 'Destination location',
        snippet: 'Destination place',
      ),
    );

    _markers[markerId] = destinationMarker;
    _markerList.sink.add(_markers);
  }

  Future<void> setPolyline(
    ({double lat, double lng}) origin,
    ({double lat, double lng}) destination,
    Color polylineColor,
  ) async {
    final direction = await mapsClient.getDirectionsFromPositions(
      origin,
      destination,
    );
    if (direction == null) return;

    final pointList = <LatLng>[];
    for (final step in direction.steps) {
      _decodePolyLine(step.polyline.points).forEach(pointList.add);
    }

    const polyId = PolylineId('polyline');
    _polyLines[polyId] = Polyline(
      polylineId: polyId,
      points: pointList,
      color: polylineColor,
      width: 5,
    );

    _polylineList.sink.add(_polyLines);
    _routeData.sink.add(
      RouteData(bounds: direction.bounds, km: direction.km, eta: direction.eta),
    );
  }

  void clearMap() {
    _polylineList.sink.add(<PolylineId, Polyline>{});
    _routeData.sink.add(null);
  }

  void dispose() {
    _markerList.close();
    _polylineList.close();
    _routeData.close();
  }

  List<LatLng> _decodePolyLine(String encoded) {
    final poly = <LatLng>[];
    final len = encoded.length;

    var index = 0;
    var lat = 0;
    var lng = 0;

    while (index < len) {
      int b;
      var shift = 0;
      var result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final dLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dLat;
      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final dLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dLng;

      final p = LatLng(lat.toDouble() / 1E5, lng.toDouble() / 1E5);
      poly.add(p);
    }

    return poly;
  }
}

final mapBloc = MapBloc(mapsClient: MapsClient());

class RouteData {
  RouteData({required this.bounds, required this.km, required this.eta});

  ws.Bounds bounds;
  String km;
  String eta;
}
