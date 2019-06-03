import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_maps_bloc/bloc/geo_position_bloc.dart';
import 'package:flutter_maps_bloc/bloc/map_bloc.dart';
import 'package:flutter_maps_bloc/ui/search_place_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _geoPositionBloc = GeoPositionBloc();
  final _mapBloc = MapBloc();

  bool _isRoteActivated = false;

  /// Google maps
  Completer<GoogleMapController> _controller = Completer();

  /// Position origin
  double _originLat;
  double _originLng;

  /// Position destination
  double _destinationLat;
  double _destinationLng;

  /// Override functions
  @override
  void initState() {
    super.initState();
    _geoPositionBloc.init();
  }

  @override
  void dispose() {
    _geoPositionBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Position>(
      stream: _geoPositionBloc.position,
      builder: (context, positionSnapShot) {
        if (positionSnapShot.hasData) {
          _originLat = positionSnapShot.data.latitude;
          _originLng = positionSnapShot.data.longitude;

          if (_originLat != null && _originLng != null) {
            _mapBloc.setOriginMarkers(_originLat, _originLng);
            return _setFullMap();
          } else {
            return _setError("Error al obtener la posición");
          }
        } else if (positionSnapShot.hasError) {
          return _setError(positionSnapShot.error);
        } else {
          return _setLoading();
        }
      },
    );
  }

  /// Widget functions
  Widget _setFullMap() {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: StreamBuilder<Map<MarkerId, Marker>>(
            initialData: {},
            stream: _mapBloc.markerList,
            builder: (context, mapSnapshot) {
              return StreamBuilder<PolyLineData>(
                  stream: _mapBloc.polylineData,
                  builder: (context, polylineSnapshot) {
                    if (polylineSnapshot.hasData && _isRoteActivated) {
                      _setFixCamera(polylineSnapshot.data.bounds);
                    }

                    return GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(_originLat, _originLng),
                        zoom: 15,
                      ),
                      onMapCreated: (controller) =>
                          _controller.complete(controller),
                      mapType: MapType.normal,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      markers: Set<Marker>.of(mapSnapshot.data.length > 0
                          ? mapSnapshot.data.values
                          : []),
                      polylines: Set<Polyline>.of(polylineSnapshot.hasData &&
                              polylineSnapshot.data.polyLines.length > 0
                          ? polylineSnapshot.data.polyLines.values
                          : []),
                    );
                  });
            }),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            heroTag: "Search",
            onPressed: () async {
              List<dynamic> data = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SearchPlaceScreen(lat: _originLat, lng: _originLng),
                ),
              );

              if (data != null) {
                _destinationLat = data[1];
                _destinationLng = data[2];

                print("d lat: $_destinationLat --- d lng: $_destinationLng");
                _goToDestination();
              }
            },
            child: Icon(Icons.search),
            tooltip: "Search",
          ),
          SizedBox(height: 5),
          FloatingActionButton(
            heroTag: "Location",
            onPressed: _goToOrigin,
            child: Icon(Icons.my_location),
            tooltip: "Current location",
          ),
          SizedBox(height: 5),
          (_destinationLat != null && _destinationLng != null)
              ? FloatingActionButton(
                  heroTag: "Directions",
                  onPressed: _goToDestination,
                  child: Icon(Icons.directions),
                  tooltip: "Destination location",
                )
              : Container(),
          (_destinationLat != null && _destinationLng != null)
              ? SizedBox(height: 5)
              : Container(),
          (_destinationLat != null && _destinationLng != null)
              ? FloatingActionButton(
                  heroTag: "Directions car",
                  onPressed: () {
                    _isRoteActivated = true;
                    _mapBloc.setPolyline(_originLat, _originLng,
                        _destinationLat, _destinationLng);
                  },
                  child: Icon(Icons.directions_car),
                  tooltip: "Get route",
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _setError(String text) {
    return Scaffold(
      body: Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 25, color: Colors.red),
        ),
      ),
    );
  }

  Widget _setLoading() {
    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Loading map",
              style: TextStyle(fontSize: 25, color: Colors.blueAccent),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  /// Functions
  Future<void> _goToOrigin() async {
    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(_originLat, _originLng),
        zoom: 16,
        bearing: 0,
        tilt: 0,
      )),
    );
  }

  Future<void> _goToDestination() async {
    if (_destinationLat != null && _destinationLng != null) {
      _isRoteActivated = false;

      final GoogleMapController controller = await _controller.future;
      final currentLatLng = LatLng(_destinationLat, _destinationLng);

      controller.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(
          target: currentLatLng,
          zoom: 16,
          bearing: 90,
          tilt: 45,
        )),
      );

      _mapBloc.setDestinationMarker(_destinationLat, _destinationLng);
    }
  }

  Future _setFixCamera(bounds) async {
    final GoogleMapController controller = await _controller.future;

    var southWest = LatLng(bounds.southwest.lat, bounds.southwest.lng);
    var northEast = LatLng(bounds.northeast.lat, bounds.northeast.lng);

    controller.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: southWest, northeast: northEast), 40));
  }
}
