import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps_app/core/bloc/settings_bloc.dart';
import 'package:flutter_maps_app/core/client/maps_client.dart';
import 'package:flutter_maps_app/core/model/map_models.dart';
import 'package:flutter_maps_app/features/home/presentation/bloc/map_bloc.dart';
import 'package:flutter_maps_app/features/search_place/presentation/view/search_place_view.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/directions.dart' as directions;

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

    context.read<SingleBloc>()
      ..add(const StartPositionStreamEvent())
      ..add(const InitMapModeEvent());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: BlocConsumer<SingleBloc, SingleState>(
        listenWhen: (_, current) => current.position != null,
        listener: (_, state) => context.read<MapBloc>().add(
          SetOriginMarkerEvent(
            lat: state.position!.latitude,
            lng: state.position!.longitude,
          ),
        ),
        builder: (_, state) {
          if (state.position != null) {
            return Scaffold(
              body: SizedBox.fromSize(
                size: Size(size.width, size.height),
                child: BlocConsumer<MapBloc, MapState>(
                  listener: (_, mapState) {
                    if (mapState.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(mapState.errorMessage!),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  builder: (_, mapState) {
                    if (mapState.polylines.isNotEmpty && _isRouteActivated) {
                      if (mapState.routeData != null) {
                        _setFixCamera(mapState.routeData!.bounds);
                      }
                    }
                    final origin = mapState.origin;

                    return Stack(
                      fit: .expand,
                      children: <Widget>[
                        if (origin != null)
                          GoogleMap(
                            key: ValueKey(state.mapModeStyle.hashCode),
                            markers: Set<Marker>.of(mapState.markers.values),
                            polylines: Set<Polyline>.of(
                              mapState.polylines.values,
                            ),
                            initialCameraPosition: CameraPosition(
                              target: LatLng(origin.lat, origin.lng),
                              zoom: 15,
                            ),
                            myLocationEnabled: true,
                            mapToolbarEnabled: false,
                            myLocationButtonEnabled: false,
                            style: state.mapModeStyle.isNotEmpty
                                ? state.mapModeStyle
                                : null,
                            onMapCreated: (controller) {
                              _googleMapController = controller;
                            },
                          ),
                        if (mapState.isLoadingRoute)
                          const ColoredBox(
                            color: Colors.black26,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                      ],
                    );
                  },
                ),
              ),
              floatingActionButton: BlocBuilder<MapBloc, MapState>(
                builder: (_, mapState) => Column(
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
                    if (mapState.destination != null) ...[
                      FloatingActionButton(
                        heroTag: 'Directions',
                        onPressed: _goToDestination,
                        tooltip: 'Destination location',
                        child: const Icon(Icons.directions),
                      ),
                      FloatingActionButton(
                        heroTag: 'Directions car',
                        onPressed: _setRoutePolyline,
                        tooltip: 'Get route',
                        child: const Icon(Icons.directions_car),
                      ),
                    ],
                    FloatingActionButton(
                      heroTag: 'settings',
                      onPressed: _showModalBottomSheet,
                      tooltip: 'Settings',
                      child: const Icon(Icons.settings),
                    ),
                  ],
                ),
              ),
            );
          } else if (state.errorMessage != null) {
            return SizedBox(
              width: size.width,
              child: Center(
                child: Text(
                  state.errorMessage!,
                  style: const TextStyle(fontSize: 25, color: Colors.red),
                ),
              ),
            );
          } else {
            return SizedBox(
              width: size.width,
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

  Future<void> _goToSearch() async {
    final origin = context.read<MapBloc>().state.origin;
    if (origin == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute<List<dynamic>>(
        builder: (_) => SearchPlacePage(lat: origin.lat, lng: origin.lng),
      ),
    );

    if (result != null && mounted) {
      context.read<MapBloc>().add(const ClearMapEvent());
      context.read<MapBloc>().add(
        SetDestinationMarkerEvent(
          lat: result[1] as double,
          lng: result[2] as double,
        ),
      );
      Future.delayed(const Duration(seconds: 1), _goToDestination);
    }
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
    context.read<MapBloc>().add(
      SetPolylineEvent(
        origin: (lat: state.origin!.lat, lng: state.origin!.lng),
        destination: (lat: state.destination!.lat, lng: state.destination!.lng),
        polylineColor: Colors.blue,
      ),
    );
  }

  void _setFixCamera(directions.Bounds bounds) {
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

  Future<void> _showModalBottomSheet() async {
    final result = await showModalBottomSheet<MapMode>(
      context: context,
      builder: (_) {
        final mapModes = <({String text, MapMode mode})>[
          (text: 'Night', mode: .night),
          (text: 'Night Blue', mode: .nightBlue),
          (text: 'Personal', mode: .personal),
          (text: 'Uber', mode: .uber),
          (text: 'Default', mode: .none),
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
                    onPressed: () => Navigator.of(context).pop(item.mode),
                    child: Text(item.text),
                  ),
              ],
            ],
          ),
        );
      },
    );

    if (result != null && mounted) {
      context.read<SingleBloc>().add(ChangeMapModeEvent(result));
    }
  }
}
