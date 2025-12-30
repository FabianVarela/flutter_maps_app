import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps_app/core/client/maps_client.dart';
import 'package:flutter_maps_app/core/model/map_models.dart';
import 'package:flutter_maps_app/features/drag_map/presentation/view/drag_map_screen.dart';
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

class SearchPlaceView extends StatefulWidget {
  const SearchPlaceView({required this.lat, required this.lng, super.key});

  final double lat;
  final double lng;

  @override
  State<SearchPlaceView> createState() => _SearchPlaceViewState();
}

class _SearchPlaceViewState extends State<SearchPlaceView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search address'), centerTitle: true),
      body: Column(
        spacing: 20,
        children: <Widget>[
          Padding(
            padding: const .all(8),
            child: TextField(
              decoration: const InputDecoration(hintText: 'Type the address'),
              onChanged: (value) => context.read<SearchPlaceBloc>().add(
                SearchPlaceQueryEvent(
                  query: value,
                  position: (lat: widget.lat, lng: widget.lng),
                ),
              ),
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
                    shrinkWrap: true,
                    itemCount: state.places.length,
                    itemBuilder: (_, index) => ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(state.places[index].formattedAddress ?? ''),
                      onTap: () => _selectPlace(state.places[index]),
                    ),
                  );
                }

                return const Offstage();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'Place Map',
        onPressed: _onDragMap,
        tooltip: 'Get destination from map',
        child: const Icon(Icons.person_pin_circle),
      ),
    );
  }

  void _selectPlace(PlacesSearchResult place) {
    FocusScope.of(context).requestFocus(FocusNode());
    final location = place.geometry?.location;

    _returnToMapScreen(
      place.formattedAddress ?? '',
      (lat: location?.lat ?? 0, lng: location?.lng ?? 0),
    );
  }

  Future<void> _onDragMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute<DragMapData>(
        builder: (_) => DragMapScreen(lat: widget.lat, lng: widget.lng),
      ),
    );

    if (result != null) {
      _returnToMapScreen(
        result.formattedAddress ?? '',
        (lat: result.latitude, lng: result.longitude),
      );
    }
  }

  void _returnToMapScreen(String address, ({double lat, double lng}) position) {
    Navigator.pop(context, <dynamic>[address, position.lat, position.lng]);
  }
}
