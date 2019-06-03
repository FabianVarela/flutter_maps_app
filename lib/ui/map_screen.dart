import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_maps_bloc/bloc/geo_position_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _geoPositionBloc = GeoPositionBloc();

  /// Google maps
  Completer<GoogleMapController> _controller = Completer();

  /// Position and marker origin
  double _originLat;
  double _originLng;

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
            return _setFullMap();
          } else {
            return _setError("Error al obtener la posición");
          }
        } else if (positionSnapShot.hasError) {
          return _setError(positionSnapShot.error);
        } else {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  Widget _setFullMap() {
    return Scaffold(
      body: _setMap(),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: _setFABs(),
      ),
    );
  }

  Widget _setMap() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(_originLat, _originLng),
          zoom: 15,
        ),
        onMapCreated: (controller) => _controller.complete(controller),
        mapType: MapType.normal,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
      ),
    );
  }

  List<Widget> _setFABs() {
    return <Widget>[
      FloatingActionButton(
        heroTag: "Location",
        onPressed: null, //_goToOrigin,
        child: Icon(Icons.my_location),
        tooltip: "Current location",
      ),
      SizedBox(height: 5),
      FloatingActionButton(
        heroTag: "Directions",
        onPressed: null, //_goToDestination,
        child: Icon(Icons.directions),
        tooltip: "Destination location",
      ),
    ];
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
}
