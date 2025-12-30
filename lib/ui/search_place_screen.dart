import 'package:flutter/material.dart';
import 'package:flutter_maps_app/bloc/drag_map_bloc.dart';
import 'package:flutter_maps_app/bloc/search_place_bloc.dart';
import 'package:flutter_maps_app/ui/drag_map_screen.dart';
import 'package:google_maps_webservice/places.dart';

class SearchPlaceScreen extends StatefulWidget {
  const SearchPlaceScreen({required this.lat, required this.lng, super.key});

  final double lat;
  final double lng;

  @override
  State<SearchPlaceScreen> createState() => _SearchPlaceScreenState();
}

class _SearchPlaceScreenState extends State<SearchPlaceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search address'), centerTitle: true),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const .all(8),
            child: TextField(
              decoration: const InputDecoration(hintText: 'Type the address'),
              onChanged: (value) {
                searchPlaceBloc.searchPlace(value, widget.lat, widget.lng);
              },
            ),
          ),
          Padding(
            padding: const .only(top: 20),
            child: StreamBuilder<bool>(
              stream: searchPlaceBloc.isLoading,
              builder: (_, loadingSnapshot) {
                if (loadingSnapshot.hasData) {
                  if (loadingSnapshot.data ?? false) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return StreamBuilder<List<PlacesSearchResult>>(
                      stream: searchPlaceBloc.placeList,
                      builder: (_, placesSnapshot) {
                        if (placesSnapshot.hasData) {
                          if (placesSnapshot.data!.isNotEmpty) {
                            final places = placesSnapshot.data!;

                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: places.length,
                              itemBuilder: (_, index) => ListTile(
                                leading: const Icon(Icons.location_on),
                                title: Text(
                                  places[index].formattedAddress ?? '',
                                ),
                                onTap: () => _selectPlace(places[index]),
                              ),
                            );
                          }
                        }
                        return const Offstage();
                      },
                    );
                  }
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
    _returnToMapScreen(
      place.formattedAddress ?? '',
      place.geometry?.location.lat ?? 0,
      place.geometry?.location.lng ?? 0,
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
        result.latitude,
        result.longitude,
      );
    }
  }

  void _returnToMapScreen(String address, double lat, double lng) {
    Navigator.pop(context, <dynamic>[address, lat, lng]);
  }
}
