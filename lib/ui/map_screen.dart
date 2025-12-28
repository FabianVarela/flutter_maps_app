import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps_app/bloc/map_bloc.dart';
import 'package:flutter_maps_app/bloc/single_bloc.dart';
import 'package:flutter_maps_app/ui/search_place_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/directions.dart' as directions;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapBloc = MapBloc();

  bool _isRoteActivated = false;

  late GoogleMapController? _googleMapController;

  double? _originLat;
  double? _originLng;

  double? _destinationLat;
  double? _destinationLng;

  @override
  void initState() {
    super.initState();

    singleBloc
      ..setPosition()
      ..init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<Position>(
        stream: singleBloc.position,
        builder: (_, positionSnapshot) {
          if (positionSnapshot.hasData) {
            _originLat = positionSnapshot.data!.latitude;
            _originLng = positionSnapshot.data!.longitude;

            if (_originLat != null && _originLng != null) {
              _mapBloc.setOriginMarkers(_originLat!, _originLng!);
              return _setFullMap();
            } else {
              return SizedBox(
                width: MediaQuery.sizeOf(context).width,
                child: const Center(
                  child: Text(
                    'An error has ocurred while get the position',
                    style: TextStyle(fontSize: 25, color: Colors.red),
                  ),
                ),
              );
            }
          } else if (positionSnapshot.hasError) {
            return SizedBox(
              width: MediaQuery.sizeOf(context).width,
              child: Center(
                child: Text(
                  positionSnapshot.error.toString(),
                  style: const TextStyle(fontSize: 25, color: Colors.red),
                ),
              ),
            );
          } else {
            return SizedBox(
              width: MediaQuery.sizeOf(context).width,
              child: const Column(
                spacing: 20,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Loading map',
                    style: TextStyle(fontSize: 25, color: Colors.blueAccent),
                  ),
                  CircularProgressIndicator(),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _setFullMap() {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: SizedBox.fromSize(
        size: Size(size.width, size.height),
        child: StreamBuilder<Map<MarkerId, Marker>>(
          initialData: const <MarkerId, Marker>{},
          stream: _mapBloc.markerList,
          builder: (_, mapSnapshot) => StreamBuilder<Map<PolylineId, Polyline>>(
            initialData: const <PolylineId, Polyline>{},
            stream: _mapBloc.polylineList,
            builder: (_, polylineSnapshot) => StreamBuilder<RouteData?>(
              stream: _mapBloc.routeData,
              builder: (_, routeSnapshot) {
                if (polylineSnapshot.hasData && _isRoteActivated) {
                  if (polylineSnapshot.data != null) {
                    _setFixCamera(routeSnapshot.data!.bounds);
                  }
                }

                return StreamBuilder<String>(
                  initialData: '',
                  stream: singleBloc.mapMode,
                  builder: (_, mapModeSnapshot) => GoogleMap(
                    markers: Set<Marker>.of((mapSnapshot.data ?? {}).values),
                    polylines: Set<Polyline>.of(
                      (polylineSnapshot.data ?? {}).values,
                    ),
                    initialCameraPosition: CameraPosition(
                      target: LatLng(_originLat!, _originLng!),
                      zoom: 15,
                    ),
                    myLocationEnabled: true,
                    mapToolbarEnabled: false,
                    myLocationButtonEnabled: false,
                    style: mapModeSnapshot.data,
                    onMapCreated: (controller) {
                      _googleMapController = controller;
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        spacing: 5,
        mainAxisAlignment: .end,
        crossAxisAlignment: .end,
        children: <Widget>[
          FloatingActionButton(
            heroTag: 'Search',
            onPressed: _goToSearch,
            tooltip: 'Search',
            child: const Icon(Icons.search),
          ),
          FloatingActionButton(
            heroTag: 'Location',
            onPressed: _goToOrigin,
            tooltip: 'Current location',
            child: const Icon(Icons.my_location),
          ),
          if (_destinationLat != null && _destinationLng != null)
            FloatingActionButton(
              heroTag: 'Directions',
              onPressed: _goToDestination,
              tooltip: 'Destination location',
              child: const Icon(Icons.directions),
            ),
          if (_destinationLat != null && _destinationLng != null)
            FloatingActionButton(
              heroTag: 'Directions car',
              onPressed: _setRoutePolyline,
              tooltip: 'Get route',
              child: const Icon(Icons.directions_car),
            ),
          FloatingActionButton(
            heroTag: 'settings',
            onPressed: _showModalBottomSheet,
            tooltip: 'Settings',
            child: const Icon(Icons.settings),
          ),
        ],
      ),
    );
  }

  Future<void> _goToSearch() async {
    final data = await Navigator.push(
      context,
      MaterialPageRoute<List<dynamic>>(
        builder: (_) => SearchPlaceScreen(lat: _originLat!, lng: _originLng!),
      ),
    );

    if (data != null) {
      _mapBloc.clearMap();

      _destinationLat = data[1] as double;
      _destinationLng = data[2] as double;

      if (kDebugMode) {
        print('d lat: $_destinationLat --- d lng: $_destinationLng');
      }
      _goToDestination();
    }
  }

  void _goToOrigin() {
    _googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(_originLat!, _originLng!), zoom: 16),
      ),
    );
  }

  void _goToDestination() {
    if (_destinationLat != null && _destinationLng != null) {
      _isRoteActivated = false;

      final currentLatLng = LatLng(_destinationLat!, _destinationLng!);
      final cameraPosition = CameraUpdate.newCameraPosition(
        CameraPosition(target: currentLatLng, zoom: 16, bearing: 90, tilt: 45),
      );

      _googleMapController?.animateCamera(cameraPosition);
      _mapBloc.setDestinationMarker(_destinationLat!, _destinationLng!);
    }
  }

  void _setRoutePolyline() {
    _isRoteActivated = true;
    _mapBloc.setPolyline(
      (lat: _originLat!, lng: _originLng!),
      (lat: _destinationLat!, lng: _destinationLng!),
      Colors.blue,
    );
  }

  void _setFixCamera(directions.Bounds bounds) {
    final southWest = LatLng(bounds.southwest.lat, bounds.southwest.lng);
    final northEast = LatLng(bounds.northeast.lat, bounds.northeast.lng);

    _googleMapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: southWest, northeast: northEast),
        40,
      ),
    );
  }

  void _showModalBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) {
        final mapModes = <({String text, String mode})>[
          (text: 'Night', mode: 'night_mode'),
          (text: 'Night Blue', mode: 'night_blue_mode'),
          (text: 'Personal', mode: 'personal_mode'),
          (text: 'Uber', mode: 'uber_mode'),
          (text: 'Default', mode: ''),
        ];

        return Padding(
          padding: const .all(40),
          child: Column(
            spacing: 5,
            mainAxisSize: .min,
            crossAxisAlignment: .stretch,
            children: <Widget>[
              const Padding(
                padding: .only(bottom: 5),
                child: Text('Selecciona una opción para el modo del mapa'),
              ),
              ...[
                for (final item in mapModes)
                  ElevatedButton(
                    onPressed: () {
                      singleBloc.changeMapMode(item.mode);
                      Navigator.of(context).pop();
                    },
                    child: Text(item.text),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}
