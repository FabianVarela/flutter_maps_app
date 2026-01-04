part of '../view/map_view.dart';

class MapWidget extends StatelessWidget {
  const MapWidget({
    required this.onMapCreated,
    required this.onGoToDestination,
    super.key,
  });

  final ValueSetter<GoogleMapController>? onMapCreated;
  final VoidCallback onGoToDestination;

  @override
  Widget build(BuildContext context) {
    final mapModeStyle = context.select<SingleBloc, String>(
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

    if (result != null && context.mounted) {
      context.read<SingleBloc>().add(ChangeMapModeEvent(result));
    }
  }
}
