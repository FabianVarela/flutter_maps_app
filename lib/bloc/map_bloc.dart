import 'package:flutter_maps_bloc/bloc/base_bloc.dart';
import 'package:flutter_maps_bloc/common/google_api_key.dart';
import 'package:flutter_maps_bloc/common/preferences.dart';
import 'package:rxdart/rxdart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/directions.dart' as webService;
import 'package:flutter/services.dart' show rootBundle;

class MapBloc with GoogleApiKey, Preferences implements BaseBloc {
  Map<MarkerId, Marker> _markers = {};
  Map<PolylineId, Polyline> _polyLines = {};

  /// Subjects or StreamControllers
  final _mapMode = BehaviorSubject<String>();
  final _markerList = BehaviorSubject<Map<MarkerId, Marker>>();
  final _polylineData = BehaviorSubject<PolyLineData>();

  /// Observables
  Observable<String> get mapMode => _mapMode.stream;

  Observable<Map<MarkerId, Marker>> get markerList => _markerList.stream;

  Observable<PolyLineData> get polylineData => _polylineData.stream;

  /// Functions
  void init() async {
    final mapMode = await getMapMode();

    try {
      final mapFileData = await _getFileData('assets/$mapMode.json');
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
      double destinationLng) async {
    final directions = webService.GoogleMapsDirections(apiKey: getApiKey());
    final response = await directions.directionsWithLocation(
        webService.Location(originLat, originLng),
        webService.Location(destinationLat, destinationLng));

    final steps = response.routes[0].legs[0].steps;
    final eta = response.routes[0].legs[0].duration.text;
    final km = response.routes[0].legs[0].distance.text;
    final bounds = response.routes[0].bounds;

    steps.asMap().forEach((index, step) {
      print("start loc $index: ${step.startLocation}");
      print("end loc $index: ${step.endLocation}");

      var id = PolylineId('polyline_id_$index');

      _polyLines[id] = Polyline(polylineId: id, points: [
        LatLng(step.startLocation.lat, step.startLocation.lng),
        LatLng(step.endLocation.lat, step.endLocation.lng),
      ]);
    });

    print("ETA: $eta");
    print("Km: $km");

    _polylineData.sink.add(PolyLineData(_polyLines, bounds, km, eta));
  }

  void changeMapMode(String mode) async {
    await saveMapMode(mode);
    init();
  }

  /// Private methods
  Future<String> _getFileData(String path) async =>
      await rootBundle.loadString(path);

  /// Override functions
  @override
  void dispose() {
    _mapMode.close();
    _markerList.close();
    _polylineData.close();
  }
}

class PolyLineData {
  Map<PolylineId, Polyline> polyLines;
  webService.Bounds bounds;
  String km;
  String eta;

  PolyLineData(this.polyLines, this.bounds, this.km, this.eta);
}
