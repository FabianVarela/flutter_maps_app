import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps_app/core/bloc/settings_bloc.dart';
import 'package:flutter_maps_app/core/client/maps_client.dart';
import 'package:flutter_maps_app/features/drag_map/presentation/bloc/drag_map_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DragMapPage extends StatelessWidget {
  const DragMapPage({required this.lat, required this.lng, super.key});

  final double lat;
  final double lng;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DragMapBloc(mapsClient: context.read<MapsClient>()),
      child: DragMapView(lat: lat, lng: lng),
    );
  }
}

class DragMapView extends StatefulWidget {
  const DragMapView({required this.lat, required this.lng, super.key});

  final double lat;
  final double lng;

  @override
  State<DragMapView> createState() => _DragMapViewState();
}

class _DragMapViewState extends State<DragMapView> {
  late LatLng _position;
  late GoogleMapController? _googleMapController;

  int _markerIdCounter = 0;

  @override
  void initState() {
    super.initState();
    _position = LatLng(widget.lat, widget.lng);

    context.read<SingleBloc>().add(const InitMapModeEvent());
    context.read<DragMapBloc>().add(
      GetInitialPositionEvent(latLng: _position, idMarker: _markerIdValue()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final mapModeStyle = context.select<SingleBloc, String>(
      (bloc) => bloc.state.mapModeStyle,
    );

    return Scaffold(
      body: SizedBox.fromSize(
        size: Size(size.width, size.height),
        child: BlocConsumer<DragMapBloc, DragMapState>(
          listener: (_, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (_, dragMapState) => GoogleMap(
            key: ValueKey(mapModeStyle.hashCode),
            markers: Set<Marker>.of(dragMapState.markers.values),
            initialCameraPosition: CameraPosition(target: _position, zoom: 12),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            style: mapModeStyle.isEmpty ? null : mapModeStyle,
            onMapCreated: _onMapCreated,
            onCameraMove: (position) {
              if (!dragMapState.isFirstTime) {
                if (dragMapState.markers.isNotEmpty) {
                  _position = position.target;
                  context.read<DragMapBloc>().add(
                    DragMarkerEvent(
                      latLng: _position,
                      idMarker: _markerIdValue(),
                    ),
                  );
                }
              }
            },
            onCameraIdle: () {
              if (!dragMapState.isFirstTime) {
                context.read<DragMapBloc>().add(
                  GetAddressEvent(
                    lat: _position.latitude,
                    lng: _position.longitude,
                  ),
                );
              }
            },
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
          BlocBuilder<DragMapBloc, DragMapState>(
            builder: (_, state) => FloatingActionButton(
              heroTag: 'Ok position',
              onPressed: state.dragMapData != null
                  ? () => Navigator.of(context).pop(state.dragMapData)
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

  String _markerIdValue({bool increment = false}) {
    final val = 'marker_id_$_markerIdCounter';
    if (increment) _markerIdCounter++;

    return val;
  }
}
