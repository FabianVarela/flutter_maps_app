import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps_app/core/bloc/settings_bloc.dart';
import 'package:flutter_maps_app/core/client/maps_client.dart';
import 'package:flutter_maps_app/features/drag_map/presentation/bloc/drag_map_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part '../widgets/address_section.dart';

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
    context.read<DragMapBloc>().add(
      GetInitialPositionEvent(latLng: _position, idMarker: _markerIdValue()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapModeStyle = context.select<SingleBloc, String>(
      (bloc) => bloc.state.mapModeStyle,
    );

    return BlocListener<DragMapBloc, DragMapState>(
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
      child: Scaffold(
        backgroundColor: const Color(0xFF1E1E1E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF2C2C2C),
          foregroundColor: Colors.white,
          title: const Text(
            'Confirmar Ubicación',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        body: Stack(
          fit: .expand,
          children: <Widget>[
            BlocBuilder<DragMapBloc, DragMapState>(
              builder: (_, state) => GoogleMap(
                key: ValueKey(mapModeStyle.hashCode),
                markers: Set<Marker>.of(state.markers.values),
                initialCameraPosition: CameraPosition(
                  target: _position,
                  zoom: 12,
                ),
                myLocationEnabled: true,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                style: mapModeStyle.isEmpty ? null : mapModeStyle,
                onMapCreated: _onMapCreated,
                onCameraMove: (position) {
                  if (!state.isFirstTime && state.markers.isNotEmpty) {
                    _position = position.target;
                    context.read<DragMapBloc>().add(
                      DragMarkerEvent(
                        latLng: _position,
                        idMarker: _markerIdValue(),
                      ),
                    );
                  }
                },
                onCameraIdle: () {
                  if (state.isFirstTime) return;
                  context.read<DragMapBloc>().add(
                    GetAddressEvent(
                      lat: _position.latitude,
                      lng: _position.longitude,
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: .bottomCenter,
              child: _AddressSection(onGoToOrigin: _goToOrigin),
            ),
          ],
        ),
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
