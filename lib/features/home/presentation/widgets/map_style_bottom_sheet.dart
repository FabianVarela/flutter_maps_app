part of '../view/map_view.dart';

class _MapStyleBottomSheet extends HookWidget {
  const _MapStyleBottomSheet();

  @override
  Widget build(BuildContext context) {
    final currentMapMode = context.select<SettingsBloc, MapMode>(
      (bloc) => bloc.state.mapMode,
    );
    final selectedMapMode = useState(currentMapMode);

    const images = Assets.images;
    final styleOptions = [
      (title: 'Default', path: images.defaultMode, mode: MapMode.none),
      (title: 'Night', path: images.nightMode, mode: MapMode.night),
      (
        title: 'Night blue',
        path: images.nightBlueMode,
        mode: MapMode.nightBlue,
      ),
      (title: 'Uber', path: images.uberMode, mode: MapMode.uber),
      (title: 'Personal', path: images.personalMode, mode: MapMode.personal),
    ];

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * .8,
      child: Padding(
        padding: const .fromLTRB(24, 0, 24, 24),
        child: Column(
          spacing: 24,
          children: <Widget>[
            Column(
              crossAxisAlignment: .start,
              children: <Widget>[
                Row(
                  spacing: 12,
                  children: <Widget>[
                    const Expanded(
                      child: Text(
                        'Estilo de Mapa',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: .bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Text(
                  'Selecciona una apariencia para tu navegación.',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ],
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: .85,
                children: <Widget>[
                  for (final item in styleOptions)
                    _MapStyleCard(
                      title: item.title,
                      imagePath: item.path,
                      mode: MapMode.none,
                      isSelected: selectedMapMode.value == item.mode,
                      onTap: () => selectedMapMode.value = item.mode,
                    ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(selectedMapMode.value);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                padding: const .symmetric(vertical: 12),
                backgroundColor: const Color(0xFF4285F4),
                shape: RoundedRectangleBorder(borderRadius: .circular(12)),
              ),
              child: const Text(
                'Aplicar Cambios',
                style: TextStyle(fontSize: 16, fontWeight: .w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapStyleCard extends StatelessWidget {
  const _MapStyleCard({
    required this.title,
    required this.imagePath,
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String imagePath;
  final MapMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: const Color(0xFF2C2C2C),
        clipBehavior: .antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          borderRadius: .circular(12),
          side: isSelected
              ? const BorderSide(color: Color(0xFF4285F4), width: 2)
              : .none,
        ),
        child: Column(
          spacing: 10,
          crossAxisAlignment: .stretch,
          children: <Widget>[
            Expanded(
              child: Stack(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                    child: SizedBox.square(
                      dimension: .infinity,
                      child: Image.asset(imagePath, fit: .cover),
                    ),
                  ),
                  if (isSelected)
                    const Align(
                      alignment: .topRight,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle,
                            color: Color(0xFF4285F4),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const .fromLTRB(12, 0, 12, 12),
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontWeight: .w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
