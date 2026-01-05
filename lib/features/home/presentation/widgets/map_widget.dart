part of '../view/map_view.dart';

class MapWidget extends StatelessWidget {
  const MapWidget({
    required this.onMapCreated,
    required this.onGoToDestination,
    required this.onCalculateRoute,
    required this.onClearMap,
    super.key,
  });

  final ValueSetter<GoogleMapController>? onMapCreated;
  final VoidCallback onGoToDestination;
  final VoidCallback onCalculateRoute;
  final VoidCallback onClearMap;

  @override
  Widget build(BuildContext context) {
    final mapModeStyle = context.select<SettingsBloc, String>(
      (bloc) => bloc.state.mapModeStyle,
    );

    return BlocBuilder<MapBloc, MapState>(
      builder: (_, state) => Stack(
        fit: .expand,
        children: <Widget>[
          if (state.origin != null) ...[
            GoogleMap(
              key: ValueKey(mapModeStyle.hashCode),
              markers: Set<Marker>.of(state.markers.values),
              polylines: Set<Polyline>.of(state.polylines.values),
              initialCameraPosition: CameraPosition(
                target: LatLng(state.origin!.lat, state.origin!.lng),
                zoom: 15,
              ),
              myLocationEnabled: true,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              style: mapModeStyle.isNotEmpty ? mapModeStyle : null,
              onMapCreated: onMapCreated,
            ),
            Align(
              alignment: .topCenter,
              child: SafeArea(
                child: Padding(
                  padding: const .symmetric(horizontal: 12),
                  child: Row(
                    spacing: 12,
                    children: <Widget>[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _goToSearch(context),
                          style: ElevatedButton.styleFrom(
                            padding: const .all(14),
                            foregroundColor: Colors.white70,
                            backgroundColor: const Color(0xFF3C4043),
                            shape: RoundedRectangleBorder(
                              borderRadius: .circular(16),
                            ),
                          ),
                          child: Row(
                            spacing: 12,
                            children: <Widget>[
                              const Icon(Icons.search),
                              Expanded(
                                child: Text(
                                  state.address ??
                                      'Search restaurants, gas stations, malls',
                                  maxLines: 1,
                                  overflow: .ellipsis,
                                ),
                              ),
                              const Icon(Icons.mic),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showModalBottomSheet(context),
                        child: SizedBox.square(
                          dimension: 48,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: .circular(16),
                              color: const Color(0xFF4285F4),
                            ),
                            child: const Icon(
                              Icons.settings,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          if (state.destination != null)
            Align(
              alignment: .bottomCenter,
              child: MapDestination(
                onClearMap: onClearMap,
                onGoToDestination: onGoToDestination,
                onCalculateRoute: onCalculateRoute,
              ),
            ),
          if (state.isLoadingRoute)
            const ColoredBox(
              color: Colors.black26,
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Future<void> _goToSearch(BuildContext context) async {
    final origin = context.read<MapBloc>().state.origin;
    if (origin == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute<List<dynamic>>(
        builder: (_) => SearchPlacePage(lat: origin.lat, lng: origin.lng),
      ),
    );

    if (result != null && context.mounted) {
      context.read<MapBloc>().add(const ClearMapEvent());
      context.read<MapBloc>().add(
        SetDestinationMarkerEvent(
          lat: result[1] as double,
          lng: result[2] as double,
          address: result[0] as String?,
        ),
      );
      Future.delayed(const Duration(seconds: 1), onGoToDestination);
    }
  }

  Future<void> _showModalBottomSheet(BuildContext context) async {
    final result = await showModalBottomSheet<(MapMode, bool, bool)>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: .vertical(top: .circular(20)),
      ),
      builder: (_) => const _MapStyleBottomSheet(),
    );

    if (result != null && context.mounted) {
      final (mapMode, traffic, transport) = result;

      context.read<SettingsBloc>().add(ChangeMapModeEvent(mapMode));
      context.read<SettingsBloc>().add(ToggleTrafficEvent(show: traffic));
      context.read<SettingsBloc>().add(ToggleTransportEvent(show: transport));
    }
  }
}
