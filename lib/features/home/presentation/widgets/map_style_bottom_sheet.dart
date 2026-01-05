part of '../view/map_view.dart';

class _MapStyleBottomSheet extends HookWidget {
  const _MapStyleBottomSheet();

  @override
  Widget build(BuildContext context) {
    final (mapMode, showTraffic, showTransport) = context.select(
      (SettingsBloc bloc) {
        final state = bloc.state;
        return (state.mapMode, state.showTraffic, state.showPublicTransport);
      },
    );

    final checkMapMode = useState(mapMode);
    final checkTraffic = useState(showTraffic);
    final checkTransport = useState(showTransport);

    const images = Assets.images;
    final styleOptions = <({String title, String path, MapMode mode})>[
      (title: 'Default', path: images.defaultMode, mode: .none),
      (title: 'Night', path: images.nightMode, mode: .night),
      (title: 'Night blue', path: images.nightBlueMode, mode: .nightBlue),
      (title: 'Uber', path: images.uberMode, mode: .uber),
      (title: 'Personal', path: images.personalMode, mode: .personal),
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
                      isSelected: checkMapMode.value == item.mode,
                      onTap: () => checkMapMode.value = item.mode,
                    ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            _MapOptionsSection(
              showTraffic: checkTraffic.value,
              showTransport: checkTransport.value,
              onTrafficChanged: (value) => checkTraffic.value = value,
              onTransportChanged: (value) => checkTransport.value = value,
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(
                (checkMapMode.value, checkTraffic.value, checkTransport.value),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                minimumSize: const .fromHeight(48),
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
                      top: .circular(10),
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
                        padding: .all(10),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: .circle,
                            color: Colors.white,
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

enum OptionSection { traffic, transport }

class _MapOptionsSection extends StatelessWidget {
  const _MapOptionsSection({
    required this.showTraffic,
    required this.showTransport,
    required this.onTrafficChanged,
    required this.onTransportChanged,
  });

  final bool showTraffic;
  final bool showTransport;
  final ValueChanged<bool> onTrafficChanged;
  final ValueChanged<bool> onTransportChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (final item in [OptionSection.traffic, OptionSection.transport])
          Row(
            spacing: 12,
            children: <Widget>[
              Icon(
                switch (item) {
                  .traffic => Icons.traffic,
                  .transport => Icons.directions_bus,
                },
                color: Colors.white70,
              ),
              Expanded(
                child: Text(
                  switch (item) {
                    .traffic => 'Tráfico',
                    .transport => 'Transporte público',
                  },
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              Switch(
                value: switch (item) {
                  .traffic => showTraffic,
                  .transport => showTransport,
                },
                onChanged: (value) => switch (item) {
                  .traffic => onTrafficChanged(value),
                  .transport => onTransportChanged(value),
                },
                activeThumbColor: const Color(0xFF4285F4),
                activeTrackColor: const Color(0xFF4285F4).withValues(alpha: .5),
              ),
            ],
          ),
      ],
    );
  }
}
