part of '../view/map_view.dart';

class MapDestination extends StatelessWidget {
  const MapDestination({
    required this.onClearMap,
    required this.onGoToDestination,
    required this.onCalculateRoute,
    super.key,
  });

  final VoidCallback onClearMap;
  final VoidCallback onGoToDestination;
  final VoidCallback onCalculateRoute;

  @override
  Widget build(BuildContext context) {
    final currentAddress = context.select<MapBloc, String>(
      (bloc) => bloc.state.address ?? 'Ubicación seleccionada',
    );

    final buttonOptions = [
      (
        function: onGoToDestination,
        backgroundColor: const Color(0xFF3C4043),
        icon: Icons.place,
        text: 'Ver',
      ),
      (
        function: onCalculateRoute,
        backgroundColor: const Color(0xFF4285F4),
        icon: Icons.directions_car,
        text: 'Ruta',
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: const .fromLTRB(16, 16, 16, 80),
        child: Container(
          padding: const .all(16),
          decoration: BoxDecoration(
            borderRadius: .circular(16),
            color: const Color(0xFF2C2C2C),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: Colors.black.withValues(alpha: .3),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            spacing: 12,
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: <Widget>[
              Row(
                spacing: 12,
                children: <Widget>[
                  const Icon(Icons.location_on, color: Color(0xFF4285F4)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: .start,
                      children: <Widget>[
                        const Text(
                          'Destino',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        Text(
                          currentAddress,
                          maxLines: 2,
                          overflow: .ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: .w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: onClearMap,
                    tooltip: 'Limpiar destino',
                  ),
                ],
              ),
              Row(
                spacing: 8,
                children: <Widget>[
                  for (final item in buttonOptions)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: item.function,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const .symmetric(vertical: 12),
                          backgroundColor: item.backgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: .circular(12),
                          ),
                        ),
                        icon: Icon(item.icon, size: 20),
                        label: Text(item.text),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
