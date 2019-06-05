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
  final _dragMapBloc = DragMapBloc();

  int _markerIdCounter = 0;
  LatLng _position;

  /// Google maps
  Completer<GoogleMapController> _mapController = Completer();
  GoogleMapController _googleMapController;

  /// Override functions
  @override
  void initState() {
    super.initState();
    _position = LatLng(widget.lat, widget.lng);
    _dragMapBloc.getInitialPosition(_position, _markerIdVal());
  }

  @override
  void dispose() {
    _dragMapBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _width = MediaQuery.of(context).size.width;
    var _height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: _width,
        height: _height,
        child: StreamBuilder<Map<MarkerId, Marker>>(
          initialData: {},
          stream: _dragMapBloc.markerList,
          builder: (context, markerSnapShot) {
            return StreamBuilder<bool>(
              initialData: false,
              stream: _dragMapBloc.isFirstTime,
              builder: (context, firstTimeSnapshot) {
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
                        if (markerSnapShot.data.length > 0) {
                          _position = position.target;
                          _dragMapBloc.dragMarker(_position, _markerIdVal());
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
                  print("Marker not found");
                  return Container();
                }
              },
            );
          },
        ),
      ),
      floatingActionButton: StreamBuilder(
        stream: _dragMapBloc.dragMapData,
        builder: (context, dragMapDataSnapshot) {
          return FloatingActionButton(
            heroTag: "Ok position",
            onPressed: (dragMapDataSnapshot.hasData)
                ? () => _setDirection(dragMapDataSnapshot.data)
                : null,
            child: Icon(Icons.check),
            tooltip: "Continue with position",
          );
        },
      ),
    );
  }

  /// Functions
  String _markerIdVal({bool increment = false}) {
    String val = 'marker_id_$_markerIdCounter';
    if (increment) _markerIdCounter++;

    return val;
  }

  void _onMapCreated(GoogleMapController controller) async {
    _mapController.complete(controller);

    Future.delayed(Duration(seconds: 1), () async {
      _googleMapController = await _mapController.future;
      _googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _position,
            zoom: 17.0,
          ),
        ),
      );
    });
  }

  void _setDirection(DragMapData data) => Navigator.pop(context, data);
}
