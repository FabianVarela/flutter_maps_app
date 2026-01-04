import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_maps_app/core/client/maps_client.dart';
import 'package:flutter_maps_app/core/model/map_models.dart';
import 'package:flutter_maps_app/features/drag_map/presentation/view/drag_map_view.dart';
import 'package:flutter_maps_app/features/search_place/presentation/bloc/search_place_bloc.dart';
import 'package:google_maps_webservice/places.dart';

class SearchPlacePage extends StatelessWidget {
  const SearchPlacePage({required this.lat, required this.lng, super.key});

  final double lat;
  final double lng;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchPlaceBloc(
        mapsClient: context.read<MapsClient>(),
      ),
      child: SearchPlaceView(lat: lat, lng: lng),
    );
  }
}

class SearchPlaceView extends HookWidget {
  const SearchPlaceView({required this.lat, required this.lng, super.key});

  final double lat;
  final double lng;

  @override
  Widget build(BuildContext context) {
    final showCancelButton = useState(false);
    final textController = useTextEditingController();

    final textFieldBorder = OutlineInputBorder(
      borderRadius: .circular(16),
      borderSide: const BorderSide(width: 2, color: Color(0xFF4285F4)),
    );

    useEffect(() {
      textController.addListener(() {
        showCancelButton.value = textController.text.isNotEmpty;
      });
      return null;
    }, []);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text(
          'Buscar dirección',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const .all(16),
        child: Column(
          spacing: 16,
          children: <Widget>[
            TextField(
              controller: textController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border: .none,
                fillColor: const Color(0xFF2C2C2C),
                hintText: 'Buscar dirección o lugar...',
                contentPadding: const .symmetric(horizontal: 16),
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF4285F4)),
                focusedBorder: textFieldBorder,
                enabledBorder: textFieldBorder,
                suffixIcon: showCancelButton.value
                    ? IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.white54),
                        onPressed: () {
                          textController.clear();
                          _onSearchPlace(context);
                        },
                      )
                    : null,
              ),
              onChanged: (value) => _onSearchPlace(context, value: value),
            ),
            ElevatedButton.icon(
              onPressed: () => _onDragMap(context),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                minimumSize: const .fromHeight(48),
                padding: const .symmetric(vertical: 14),
                backgroundColor: const Color(0xFF4285F4),
                shape: RoundedRectangleBorder(borderRadius: .circular(16)),
              ),
              icon: const Icon(Icons.map, size: 22),
              label: const Text(
                'Seleccionar ubicación en el mapa',
                style: TextStyle(fontSize: 16, fontWeight: .w500),
              ),
            ),
            Expanded(
              child: BlocConsumer<SearchPlaceBloc, SearchPlaceState>(
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
                builder: (_, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.places.isNotEmpty) {
                    return ListView.builder(
                      itemCount: state.places.length,
                      itemBuilder: (_, index) => ListTile(
                        leading: Icon(
                          index == 0 ? Icons.star : Icons.star_border,
                          color: index == 0
                              ? const Color(0xFF4285F4)
                              : Colors.white54,
                        ),
                        title: Text(
                          state.places[index].name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: .w500,
                          ),
                        ),
                        subtitle: Text(
                          state.places[index].formattedAddress ?? '',
                          style: const TextStyle(color: Colors.white54),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white24,
                          size: 16,
                        ),
                        onTap: () => _selectPlace(context, state.places[index]),
                      ),
                    );
                  }

                  return const Offstage();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSearchPlace(BuildContext context, {String? value}) {
    context.read<SearchPlaceBloc>().add(
      SearchPlaceQueryEvent(query: value ?? '', position: (lat: lat, lng: lng)),
    );
  }

  void _selectPlace(BuildContext context, PlacesSearchResult place) {
    FocusScope.of(context).requestFocus(FocusNode());
    final location = place.geometry?.location;

    _returnToMapScreen(
      context,
      DragMapData(
        position: (lat: location?.lat ?? 0, lng: location?.lng ?? 0),
        formattedAddress: place.formattedAddress ?? '',
      ),
    );
  }

  Future<void> _onDragMap(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute<DragMapData>(
        builder: (_) => DragMapPage(lat: lat, lng: lng),
      ),
    );
    if (result != null && context.mounted) _returnToMapScreen(context, result);
  }

  void _returnToMapScreen(BuildContext context, DragMapData mapData) {
    Navigator.of(context).pop(
      <dynamic>[
        mapData.formattedAddress,
        mapData.position.lat,
        mapData.position.lng,
      ],
    );
  }
}
