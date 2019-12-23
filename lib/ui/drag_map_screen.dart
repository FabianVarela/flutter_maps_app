import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_maps_bloc/bloc/drag_map_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DragMapScreen extends StatefulWidget {
  final double lat;
  final double lng;

  DragMapScreen({@required this.lat, @required this.lng});

  @override
  _DragMapScreenState createState() => _DragMapScreenState();
}

class _DragMapScreenState extends State<DragMapScreen> {
  final DragMapBloc _dragMapBloc = DragMapBloc();

  int _markerIdCounter = 0;
  LatLng _position;

  /// Google maps
  GoogleMapController _googleMapController;

  /// Override functions
  @override
  void initState() {
    super.initState();
    _position = LatLng(widget.lat, widget.lng);
    _dragMapBloc.getInitialPosition(_position, _markerIdVal());
    _dragMapBloc.init();
  }

  @override
  void dispose() {
    _dragMapBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double _width = MediaQuery.of(context).size.width;
    final double _height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: _width,
        height: _height,
        child: StreamBuilder<Map<MarkerId, Marker>>(
          initialData: <MarkerId, Marker>{},
          stream: _dragMapBloc.markerList,
          builder: (BuildContext context,
              AsyncSnapshot<Map<MarkerId, Marker>> markerSnapShot) {
            return StreamBuilder<String>(
              initialData: '',
              stream: _dragMapBloc.mapMode,
              builder: (BuildContext context,
                  AsyncSnapshot<String> mapModeSnapshot) {
                _setMapMode(mapModeSnapshot.data);

                return StreamBuilder<bool>(
                  initialData: false,
                  stream: _dragMapBloc.isFirstTime,
                  builder: (BuildContext context,
                      AsyncSnapshot<bool> firstTimeSnapshot) {
                    if (markerSnapShot.hasData) {
                      return GoogleMap(
                        markers: Set<Marker>.of(markerSnapShot.data.values),
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: _position,
                          zoom: 12,
                        ),
                        myLocationEnabled: true,
                        onCameraMove: (CameraPosition position) {
                          if (!firstTimeSnapshot.data) {
                            if (markerSnapShot.data.isNotEmpty) {
                              _position = position.target;
                              _dragMapBloc.dragMarker(
                                  _position, _markerIdVal());
                            }
                          }
                        },
                        onCameraIdle: () {
                          if (!firstTimeSnapshot.data) {
                            _dragMapBloc.getAddress(
                                _position.latitude, _position.longitude);
                          }
                        },
                      );
                    } else {
                      print('Marker not found');
                      return Container();
                    }
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: StreamBuilder<DragMapData>(
        stream: _dragMapBloc.dragMapData,
        builder: (BuildContext context,
            AsyncSnapshot<DragMapData> dragMapDataSnapshot) {
          return Padding(
            padding: EdgeInsets.only(bottom: 100),
            child: FloatingActionButton(
              heroTag: 'Ok position',
              onPressed: (dragMapDataSnapshot.hasData)
                  ? () => _setDirection(dragMapDataSnapshot.data)
                  : null,
              child: Icon(Icons.check),
              tooltip: 'Continue with position',
            ),
          );
        },
      ),
    );
  }

  /// Functions
  void _setMapMode(String mapMode) {
    if (_googleMapController != null)
      _googleMapController.setMapStyle(mapMode.isEmpty ? null : mapMode);
  }

  String _markerIdVal({bool increment = false}) {
    final String val = 'marker_id_$_markerIdCounter';

    if (increment) {
      _markerIdCounter++;
    }

    return val;
  }

  void _onMapCreated(GoogleMapController controller) {
    _googleMapController = controller;

    Future<dynamic>.delayed(Duration(seconds: 1), () async {
      _googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _position,
            zoom: 17,
          ),
        ),
      );
    });
  }

  void _setDirection(DragMapData data) => Navigator.pop(context, data);
}
