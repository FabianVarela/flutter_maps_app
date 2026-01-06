import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_maps_app/core/bloc/settings_bloc.dart';
import 'package:flutter_maps_app/core/client/maps_client.dart';
import 'package:flutter_maps_app/core/model/map_models.dart';
import 'package:flutter_maps_app/core/model/response/directions/compute_routes_response.dart';
import 'package:flutter_maps_app/features/home/presentation/bloc/map_bloc.dart';
import 'package:flutter_maps_app/features/search_place/presentation/view/search_place_view.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part '../widgets/map_widget.dart';

part '../widgets/map_destination.dart';

part '../widgets/map_style_bottom_sheet.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapBloc(mapsClient: context.read<MapsClient>()),
      child: const MapView(),
    );
  }
}

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  bool _isRouteActivated = false;
  GoogleMapController? _googleMapController;

  @override
  void initState() {
    super.initState();

    context.read<SettingsBloc>()
      ..add(const StartPositionStreamEvent())
      ..add(const InitMapModeEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listenWhen: (_, current) => current.position != null,
      listener: (_, state) => context.read<MapBloc>().add(
        SetOriginMarkerEvent(
          lat: state.position!.latitude,
          lng: state.position!.longitude,
        ),
      ),
      child: Scaffold(
        body: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (_, state) {
            final size = MediaQuery.sizeOf(context);
            if (state.position != null) {
              return SizedBox.fromSize(
                size: Size(size.width, size.height),
                child: BlocListener<MapBloc, MapState>(
                  listener: (_, mapState) {
                    if (mapState.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(mapState.errorMessage!),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }

                    if (mapState.polylines.isNotEmpty && _isRouteActivated) {
                      if (mapState.routeData != null) {
                        _setFixCamera(mapState.routeData!.bounds);
                      }
                    }
                  },
                  child: MapWidget(
                    onMapCreated: (controller) {
                      _googleMapController = controller;
                    },
                    onGoToDestination: _goToDestination,
                    onCalculateRoute: _setRoutePolyline,
                    onClearMap: _clearMap,
                  ),
                ),
              );
            } else if (state.errorMessage != null) {
              return SizedBox.fromSize(
                size: Size(size.width, size.height),
                child: Center(
                  child: Text(
                    state.errorMessage!,
                    style: const TextStyle(fontSize: 25, color: Colors.red),
                  ),
                ),
              );
            } else {
              return SizedBox.fromSize(
                size: Size(size.width, size.height),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        ),
        floatingActionButton: BlocSelector<SettingsBloc, SettingsState, bool>(
          selector: (state) => state.position != null,
          builder: (_, state) => switch (state) {
            false => const Offstage(),
            true => FloatingActionButton(
              heroTag: 'Location',
              onPressed: _goToOrigin,
              tooltip: 'Current location',
              backgroundColor: const Color(0xFF4285F4),
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          },
        ),
      ),
    );
  }

  void _goToOrigin() {
    final origin = context.read<MapBloc>().state.origin;
    if (origin == null) return;

    _googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(origin.lat, origin.lng), zoom: 16),
      ),
    );
  }

  void _goToDestination() {
    final destination = context.read<MapBloc>().state.destination;
    if (destination == null) return;

    _isRouteActivated = false;

    final currentLatLng = LatLng(destination.lat, destination.lng);
    _googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: currentLatLng, zoom: 16, bearing: 90, tilt: 45),
      ),
    );
  }

  void _setRoutePolyline() {
    final state = context.read<MapBloc>().state;
    if (state.origin == null || state.destination == null) return;

    _isRouteActivated = true;
    final settingState = context.read<SettingsBloc>().state;

    context.read<MapBloc>().add(
      SetPolylineEvent(
        origin: (lat: state.origin!.lat, lng: state.origin!.lng),
        destination: (lat: state.destination!.lat, lng: state.destination!.lng),
        polylineColor: Colors.blue,
        optionParams: (
          showTraffic: settingState.showTraffic,
          isTransport: settingState.showTransport,
        ),
      ),
    );
  }

  void _setFixCamera(DirectionBounds bounds) {
    _googleMapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(bounds.southwest.lat, bounds.southwest.lng),
          northeast: LatLng(bounds.northeast.lat, bounds.northeast.lng),
        ),
        40,
      ),
    );
  }

  void _clearMap() {
    _isRouteActivated = false;
    context.read<MapBloc>().add(const ClearMapEvent());
    _goToOrigin();
  }
}
