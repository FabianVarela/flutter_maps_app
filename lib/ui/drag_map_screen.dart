import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_maps_app/bloc/drag_map_bloc.dart';
import 'package:flutter_maps_app/bloc/single_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DragMapScreen extends StatefulWidget {
  const DragMapScreen({required this.lat, required this.lng, super.key});

  final double lat;
  final double lng;

  @override
  State<DragMapScreen> createState() => _DragMapScreenState();
}

class _DragMapScreenState extends State<DragMapScreen> {
  late LatLng _position;
  late GoogleMapController? _googleMapController;

  int _markerIdCounter = 0;

  @override
  void initState() {
    super.initState();

    _position = LatLng(widget.lat, widget.lng);
    dragMapBloc.getInitialPosition(_position, _markerIdVal());
    singleBloc.init();
  }

  @override
  void dispose() {
    dragMapBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: SizedBox.fromSize(
        size: Size(size.width, size.height),
        child: StreamBuilder<Map<MarkerId, Marker>>(
          initialData: const <MarkerId, Marker>{},
          stream: dragMapBloc.markerList,
          builder: (_, markerSnapShot) => StreamBuilder<String>(
            initialData: '',
            stream: singleBloc.mapMode,
            builder: (_, mapModeSnapshot) => StreamBuilder<bool>(
              initialData: false,
              stream: dragMapBloc.isFirstTime,
              builder: (_, firstTimeSnapshot) {
                if (!markerSnapShot.hasData) return const Offstage();

                return GoogleMap(
                  markers: Set<Marker>.of(markerSnapShot.data!.values),
                  initialCameraPosition: CameraPosition(
                    target: _position,
                    zoom: 12,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  style: mapModeSnapshot.data,
                  onMapCreated: _onMapCreated,
                  onCameraMove: (position) {
                    if (firstTimeSnapshot.data == false) {
                      if (markerSnapShot.data!.isNotEmpty) {
                        _position = position.target;
                        dragMapBloc.dragMarker(_position, _markerIdVal());
                      }
                    }
                  },
                  onCameraIdle: () {
                    if (firstTimeSnapshot.data == false) {
                      dragMapBloc.getAddress(
                        _position.latitude,
                        _position.longitude,
                      );
                    }
                  },
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
            heroTag: 'Location',
            onPressed: _goToOrigin,
            tooltip: 'Current location',
            child: const Icon(Icons.my_location),
          ),
          StreamBuilder<DragMapData>(
            stream: dragMapBloc.dragMapData,
            builder: (_, dragMapDataSnapshot) => FloatingActionButton(
              heroTag: 'Ok position',
              onPressed: (dragMapDataSnapshot.hasData)
                  ? () => _setDirection(dragMapDataSnapshot.data!)
                  : null,
              tooltip: 'Continue with position',
              child: const Icon(Icons.check),
            ),
          ),
        ],
      ),
    );
  }

  void _goToOrigin() {
    _googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(widget.lat, widget.lng), zoom: 16),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _googleMapController = controller;

    Future<dynamic>.delayed(const Duration(seconds: 1), () async {
      await _googleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _position, zoom: 17),
        ),
      );
    });
  }

  void _setDirection(DragMapData data) => Navigator.pop(context, data);

  String _markerIdVal({bool increment = false}) {
    final val = 'marker_id_$_markerIdCounter';
    if (increment) _markerIdCounter++;

    return val;
  }
}
