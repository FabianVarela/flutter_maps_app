import 'dart:ui';

import 'package:flutter_maps_bloc/common/google_api_key.dart';
import 'package:flutter_maps_bloc/common/utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/directions.dart' as ws;
import 'package:rxdart/rxdart.dart';

class MapBloc with GoogleApiKey {
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
    final directions = ws.GoogleMapsDirections(apiKey: mapsApiKey);
    final response = await directions.directionsWithLocation(
      ws.Location(lat: origin.lat, lng: origin.lng),
      ws.Location(lat: destination.lat, lng: destination.lng),
      travelMode: ws.TravelMode.driving,
      trafficModel: ws.TrafficModel.pessimistic,
      departureTime: DateTime.now(),
    );

    final steps = response.routes[0].legs[0].steps;
    final eta = response.routes[0].legs[0].duration.text;
    final km = response.routes[0].legs[0].distance.text;
    final bounds = response.routes[0].bounds;

    final pointList = <LatLng>[];

    for (final step in steps) {
      Utils.decodePolyLine(step.polyline.points).forEach(pointList.add);
    }

    const polyId = PolylineId('polyline');
    _polyLines[polyId] = Polyline(
      polylineId: polyId,
      points: pointList,
      color: polylineColor,
      width: 5,
    );

    _polylineList.sink.add(_polyLines);
    _routeData.sink.add(RouteData(bounds: bounds, km: km, eta: eta));
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
}

class RouteData {
  RouteData({required this.bounds, required this.km, required this.eta});

  ws.Bounds bounds;
  String km;
  String eta;
}
