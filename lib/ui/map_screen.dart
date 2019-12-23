import 'package:flutter/material.dart';
import 'package:flutter_maps_bloc/bloc/geo_position_bloc.dart';
import 'package:flutter_maps_bloc/bloc/map_bloc.dart';
import 'package:flutter_maps_bloc/bloc/single_bloc.dart';
import 'package:flutter_maps_bloc/ui/search_place_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/directions.dart' as directions;

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final GeoPositionBloc _geoPositionBloc = GeoPositionBloc();
  final MapBloc _mapBloc = MapBloc();

  bool _isRoteActivated = false;

  /// Google maps
  GoogleMapController _googleMapController;

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
    singleBloc.init();
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
      builder:
          (BuildContext context, AsyncSnapshot<Position> positionSnapShot) {
        if (positionSnapShot.hasData) {
          _originLat = positionSnapShot.data.latitude;
          _originLng = positionSnapShot.data.longitude;

          if (_originLat != null && _originLng != null) {
            _mapBloc.setOriginMarkers(_originLat, _originLng);
            return _setFullMap();
          } else {
            return _setError('Error al obtener la posición');
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
          initialData: <MarkerId, Marker>{},
          stream: _mapBloc.markerList,
          builder: (BuildContext context,
              AsyncSnapshot<Map<MarkerId, Marker>> mapSnapshot) {
            return StreamBuilder<Map<PolylineId, Polyline>>(
              initialData: <PolylineId, Polyline>{},
              stream: _mapBloc.polylineList,
              builder: (BuildContext context,
                  AsyncSnapshot<Map<PolylineId, Polyline>> polylineSnapshot) {
                return StreamBuilder<RouteData>(
                  stream: _mapBloc.routeData,
                  builder: (BuildContext context,
                      AsyncSnapshot<RouteData> routeSnapshot) {
                    if (polylineSnapshot.hasData && _isRoteActivated) {
                      _setFixCamera(routeSnapshot.data.bounds);
                    }

                    return StreamBuilder<String>(
                      initialData: '',
                      stream: singleBloc.mapMode,
                      builder: (BuildContext context,
                          AsyncSnapshot<String> mapModeSnapshot) {
                        _setMapMode(mapModeSnapshot.data);

                        return GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(_originLat, _originLng),
                            zoom: 15,
                          ),
                          onMapCreated: _onMapCreated,
                          mapType: MapType.normal,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          mapToolbarEnabled: false,
                          markers: Set<Marker>.of(mapSnapshot.data.isNotEmpty
                              ? mapSnapshot.data.values
                              : <Marker>[]),
                          polylines: Set<Polyline>.of(
                              polylineSnapshot.hasData &&
                                      polylineSnapshot.data.isNotEmpty
                                  ? polylineSnapshot.data.values
                                  : <Polyline>[]),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: _setFloatingButtons(),
      ),
    );
  }

  List<Widget> _setFloatingButtons() {
    return <Widget>[
      FloatingActionButton(
        heroTag: 'Search',
        onPressed: () async {
          final List<dynamic> data = await Navigator.push(
            context,
            MaterialPageRoute<List<dynamic>>(
              builder: (BuildContext context) =>
                  SearchPlaceScreen(lat: _originLat, lng: _originLng),
            ),
          );

          if (data != null) {
            _destinationLat = data[1];
            _destinationLng = data[2];

            print('d lat: $_destinationLat --- d lng: $_destinationLng');
            _goToDestination();
          }
        },
        child: Icon(Icons.search),
        tooltip: 'Search',
      ),
      SizedBox(height: 5),
      FloatingActionButton(
        heroTag: 'Location',
        onPressed: _goToOrigin,
        child: Icon(Icons.my_location),
        tooltip: 'Current location',
      ),
      SizedBox(height: 5),
      (_destinationLat != null && _destinationLng != null)
          ? FloatingActionButton(
              heroTag: 'Directions',
              onPressed: _goToDestination,
              child: Icon(Icons.directions),
              tooltip: 'Destination location',
            )
          : Container(),
      (_destinationLat != null && _destinationLng != null)
          ? SizedBox(height: 5)
          : Container(),
      (_destinationLat != null && _destinationLng != null)
          ? FloatingActionButton(
              heroTag: 'Directions car',
              onPressed: () {
                _isRoteActivated = true;
                _mapBloc.setPolyline(
                  _originLat,
                  _originLng,
                  _destinationLat,
                  _destinationLng,
                  Colors.blue,
                );
              },
              child: Icon(Icons.directions_car),
              tooltip: 'Get route',
            )
          : Container(),
      (_destinationLat != null && _destinationLng != null)
          ? SizedBox(height: 5)
          : Container(),
      FloatingActionButton(
        heroTag: 'settings',
        onPressed: _showModalBottomSheet,
        child: Icon(Icons.settings),
        tooltip: 'Settings',
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

  Widget _setLoading() {
    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Loading map',
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
  void _onMapCreated(GoogleMapController controller) =>
      _googleMapController = controller;

  void _setMapMode(String mapMode) {
    if (_googleMapController != null)
      _googleMapController.setMapStyle(mapMode.isEmpty ? null : mapMode);
  }

  void _goToOrigin() {
    _googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(_originLat, _originLng),
        zoom: 16,
        bearing: 0,
        tilt: 0,
      )),
    );
  }

  void _goToDestination() {
    if (_destinationLat != null && _destinationLng != null) {
      _isRoteActivated = false;

      final LatLng currentLatLng = LatLng(_destinationLat, _destinationLng);

      _googleMapController.animateCamera(
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

  void _setFixCamera(directions.Bounds bounds) {
    final LatLng southWest = LatLng(bounds.southwest.lat, bounds.southwest.lng);
    final LatLng northEast = LatLng(bounds.northeast.lat, bounds.northeast.lng);

    _googleMapController.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: southWest, northeast: northEast), 40));
  }

  void _showModalBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Selecciona una opción para el modo del mapa'),
              SizedBox(height: 10),
              RaisedButton(
                onPressed: () => singleBloc.changeMapMode('night_mode'),
                child: Text('Night'),
              ),
              SizedBox(height: 5),
              RaisedButton(
                onPressed: () => singleBloc.changeMapMode('night_blue_mode'),
                child: Text('Night Blue'),
              ),
              SizedBox(height: 5),
              RaisedButton(
                onPressed: () => singleBloc.changeMapMode('personal_mode'),
                child: Text('Personal'),
              ),
              SizedBox(height: 5),
              RaisedButton(
                onPressed: () => singleBloc.changeMapMode('uber_mode'),
                child: Text('Uber'),
              ),
              SizedBox(height: 5),
              RaisedButton(
                onPressed: () => singleBloc.changeMapMode(''),
                child: Text('Default'),
              ),
              SizedBox(height: 5),
            ],
          ),
        );
      },
    );
  }
}
