import 'dart:ui';

import 'package:flutter_maps_bloc/bloc/base_bloc.dart';
import 'package:flutter_maps_bloc/common/google_api_key.dart';
import 'package:rxdart/rxdart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/directions.dart' as ws;

class MapBloc with GoogleApiKey implements BaseBloc {
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  Map<PolylineId, Polyline> _polyLines = <PolylineId, Polyline>{};

  /// Subjects or StreamControllers
  final BehaviorSubject<Map<MarkerId, Marker>> _markerList =
      BehaviorSubject<Map<MarkerId, Marker>>();

  final BehaviorSubject<Map<PolylineId, Polyline>> _polylineList =
      BehaviorSubject<Map<PolylineId, Polyline>>();

  final BehaviorSubject<RouteData> _routeData = BehaviorSubject<RouteData>();

  /// Observables
  Observable<Map<MarkerId, Marker>> get markerList => _markerList.stream;

  Observable<Map<PolylineId, Polyline>> get polylineList =>
      _polylineList.stream;

  Observable<RouteData> get routeData => _routeData.stream;

  /// Functions
  void setOriginMarkers(double lat, double lng) {
    final MarkerId markerId = MarkerId('Current location');
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(
        title: 'Current location',
        snippet: 'Current place',
      ),
    );

    _markers[markerId] = marker;
    _markerList.sink.add(_markers);
  }

  void setDestinationMarker(double lat, double lng) {
    final MarkerId markerId = MarkerId('Destination location');
    final Marker destinationMarker = Marker(
      markerId: markerId,
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(
        title: 'Destination location',
        snippet: 'Destination place',
      ),
    );

    _markers[markerId] = destinationMarker;
    _markerList.sink.add(_markers);
  }

  void setPolyline(double originLat, double originLng, double destinationLat,
      double destinationLng, Color polylineColor) async {
    final ws.GoogleMapsDirections directions =
        ws.GoogleMapsDirections(apiKey: getApiKey());

    final ws.DirectionsResponse response =
        await directions.directionsWithLocation(
      ws.Location(originLat, originLng),
      ws.Location(destinationLat, destinationLng),
      travelMode: ws.TravelMode.driving,
      trafficModel: ws.TrafficModel.pessimistic,
      departureTime: DateTime.now(),
    );

    final List<ws.Step> steps = response.routes[0].legs[0].steps;
    final String eta = response.routes[0].legs[0].duration.text;
    final String km = response.routes[0].legs[0].distance.text;
    final ws.Bounds bounds = response.routes[0].bounds;

    final List<LatLng> pointList = List<LatLng>();

    steps.forEach((ws.Step step) {
      final ws.Polyline polyline = step.polyline;
      final String points = polyline.points;

      final List<LatLng> singlePolyLine = _decodePolyLine(points);
      singlePolyLine.forEach(pointList.add);
    });

    final PolylineId polyId = PolylineId('polyline');
    _polyLines[polyId] = Polyline(
      polylineId: polyId,
      points: pointList,
      color: polylineColor,
      width: 5,
    );

    print('ETA: $eta');
    print('Km: $km');

    _polylineList.sink.add(_polyLines);
    _routeData.sink.add(RouteData(bounds, km, eta));
  }

  /// Private methods
  List<LatLng> _decodePolyLine(String encoded) {
    final List<LatLng> poly = List<LatLng>();
    final int len = encoded.length;

    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final int dLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dLat;
      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final int dLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dLng;

      final LatLng p = LatLng(lat.toDouble() / 1E5, lng.toDouble() / 1E5);
      poly.add(p);
    }

    return poly;
  }

  /// Override functions
  @override
  void dispose() {
    _markerList.close();
    _polylineList.close();
    _routeData.close();
  }
}

class RouteData {
  ws.Bounds bounds;
  String km;
  String eta;

  RouteData(this.bounds, this.km, this.eta);
}
