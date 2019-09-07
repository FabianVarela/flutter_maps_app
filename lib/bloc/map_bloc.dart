import 'package:flutter_maps_bloc/bloc/base_bloc.dart';
import 'package:flutter_maps_bloc/common/google_api_key.dart';
import 'package:flutter_maps_bloc/common/preferences.dart';
import 'package:flutter_maps_bloc/common/utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/directions.dart' as webService;

class MapBloc with GoogleApiKey, Preferences implements BaseBloc {
  Map<MarkerId, Marker> _markers = {};
  Map<PolylineId, Polyline> _polyLines = {};

  /// Subjects or StreamControllers
  final _mapMode = BehaviorSubject<String>();
  final _markerList = BehaviorSubject<Map<MarkerId, Marker>>();
  final _polylineList = BehaviorSubject<Map<PolylineId, Polyline>>();
  final _routeData = BehaviorSubject<RouteData>();

  /// Observables
  Observable<String> get mapMode => _mapMode.stream;

  Observable<Map<MarkerId, Marker>> get markerList => _markerList.stream;

  Observable<Map<PolylineId, Polyline>> get polylineList =>
      _polylineList.stream;

  Observable<RouteData> get routeData => _routeData.stream;

  /// Functions
  void init() async {
    final mapMode = await getMapMode();

    try {
      final mapFileData = await Utils.getFileData('assets/$mapMode.json');
      _mapMode.sink.add(mapFileData);
    } catch (_) {
      _mapMode.sink.add('');
    }
  }

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

  void setDestinationMarker(double lat, double lng) {
    var markerId = MarkerId("destination location");
    var destinationMarker = Marker(
      markerId: markerId,
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(
        title: "Destination location",
        snippet: "Destination place",
      ),
    );

    _markers[markerId] = destinationMarker;
    _markerList.sink.add(_markers);
  }

  void setPolyline(double originLat, double originLng, double destinationLat,
      double destinationLng, polylineColor) async {
    final directions = webService.GoogleMapsDirections(apiKey: getApiKey());
    final response = await directions.directionsWithLocation(
      webService.Location(originLat, originLng),
      webService.Location(destinationLat, destinationLng),
      travelMode: webService.TravelMode.driving,
      trafficModel: webService.TrafficModel.pessimistic,
      departureTime: DateTime.now(),
    );

    final steps = response.routes[0].legs[0].steps;
    final eta = response.routes[0].legs[0].duration.text;
    final km = response.routes[0].legs[0].distance.text;
    final bounds = response.routes[0].bounds;

    List<LatLng> pointList = List();
    steps.forEach((step) {
      webService.Polyline polyline = step.polyline;
      String points = polyline.points;

      List<LatLng> singlePolyLine = _decodePolyLine(points);
      singlePolyLine.forEach((polyLineItem) {
        pointList.add(polyLineItem);
      });
    });

    var polyId = PolylineId('polyline');
    _polyLines[polyId] = Polyline(
      polylineId: polyId,
      points: pointList,
      color: polylineColor,
      width: 5,
    );

    print("ETA: $eta");
    print("Km: $km");

    _polylineList.sink.add(_polyLines);
    _routeData.sink.add(RouteData(bounds, km, eta));
  }

  void changeMapMode(String mode) async {
    await saveMapMode(mode);
    init();
  }

  /// Private methods
  List<LatLng> _decodePolyLine(String encoded) {
    List<LatLng> poly = List();

    int index = 0;
    int len = encoded.length;
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

      int dLat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dLat;
      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dLng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dLng;

      LatLng p = LatLng(((lat.toDouble() / 1E5)), ((lng.toDouble() / 1E5)));

      poly.add(p);
    }

    return poly;
  }

  /// Override functions
  @override
  void dispose() {
    _mapMode.close();
    _markerList.close();
    _polylineList.close();
    _routeData.close();
  }
}

class RouteData {
  webService.Bounds bounds;
  String km;
  String eta;

  RouteData(this.bounds, this.km, this.eta);
}
