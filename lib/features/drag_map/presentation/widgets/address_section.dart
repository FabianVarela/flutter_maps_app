part of '../view/drag_map_view.dart';

class _AddressSection extends StatelessWidget {
  const _AddressSection({required this.onGoToOrigin});

  final VoidCallback onGoToOrigin;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DragMapBloc, DragMapState>(
      builder: (_, state) => Padding(
        padding: const .fromLTRB(16, 16, 16, 30),
        child: Column(
          spacing: 12,
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          children: <Widget>[
            Container(
              padding: const .symmetric(vertical: 12, horizontal: 20),
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
              child: Row(
                spacing: 12,
                children: <Widget>[
                  const Icon(Icons.search, color: Color(0xFF4285F4)),
                  Expanded(
                    child: Column(
                      spacing: 4,
                      crossAxisAlignment: .start,
                      children: <Widget>[
                        const Text(
                          'UBICACIÓN SELECCIONADA',
                          style: TextStyle(
                            color: Color(0xFF4285F4),
                            fontSize: 12,
                            letterSpacing: .5,
                            fontWeight: .w500,
                          ),
                        ),
                        if (state.isLoadingAddress)
                          const SizedBox(
                            height: 20,
                            child: Center(
                              child: SizedBox.square(
                                dimension: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                          )
                        else
                          Text(
                            state.dragMapData?.formattedAddress ??
                                'Seleccionando ubicación...',
                            maxLines: 2,
                            overflow: .ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              spacing: 12,
              children: <Widget>[
                IconButton(
                  style: IconButton.styleFrom(
                    minimumSize: const .square(48),
                    backgroundColor: const Color(0xFF3C4043),
                    shape: RoundedRectangleBorder(borderRadius: .circular(16)),
                  ),
                  onPressed: onGoToOrigin,
                  icon: const Icon(Icons.my_location, color: Colors.white),
                ),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: state.dragMapData != null
                        ? () => Navigator.of(context).pop(state.dragMapData)
                        : null,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                      backgroundColor: const Color(0xFF4285F4),
                      padding: const .symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: .circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle, size: 22),
                    label: const Text(
                      'Confirmar ubicación',
                      style: TextStyle(fontSize: 16, fontWeight: .w500),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
