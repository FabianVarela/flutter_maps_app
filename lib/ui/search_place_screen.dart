import 'package:flutter/material.dart';
import 'package:flutter_maps_bloc/bloc/search_place_bloc.dart';
import 'package:flutter_maps_bloc/ui/drag_map_screen.dart';
import 'package:google_maps_webservice/places.dart';

class SearchPlaceScreen extends StatefulWidget {
  final double lat;
  final double lng;

  SearchPlaceScreen({@required this.lat, @required this.lng});

  @override
  _SearchPlaceScreenState createState() => _SearchPlaceScreenState();
}

class _SearchPlaceScreenState extends State<SearchPlaceScreen> {
  final _searchPlaceBloc = SearchPlaceBloc();

  /// Override functions
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search address"),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(hintText: "Type the city"),
              onChanged: (value) {
                _searchPlaceBloc.searchPlace(value, widget.lat, widget.lng);
              },
            ),
          ),
          SizedBox(height: 20),
          StreamBuilder<bool>(
            stream: _searchPlaceBloc.isLoading,
            builder: (context, loadingSnapshot) {
              if (loadingSnapshot.hasData) {
                if (loadingSnapshot.data)
                  return Center(child: CircularProgressIndicator());
                else
                  return _buildPlaceList();
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "Place Map",
        onPressed: () async {
          final destinationResult = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DragMapScreen(lat: widget.lat, lng: widget.lng),
            ),
          );

          if (destinationResult != null) {
            _returnToMapScreen(
              destinationResult.formattedAddress,
              destinationResult.latitude,
              destinationResult.longitude,
            );
          }
        },
        child: Icon(Icons.person_pin_circle),
        tooltip: "Get destination from map",
      ),
    );
  }

  /// Widget functions
  Widget _buildPlaceList() {
    return StreamBuilder<List<PlacesSearchResult>>(
      stream: _searchPlaceBloc.placeList,
      builder: (context, placesSnapshot) {
        if (placesSnapshot.hasData) {
          if (placesSnapshot.data.length > 0) {
            var places = placesSnapshot.data;

            return ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: places.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.location_on),
                  title: Text(places[index].formattedAddress),
                  onTap: () {
                    FocusScope.of(context).requestFocus(new FocusNode());

                    _returnToMapScreen(
                        places[index].formattedAddress,
                        places[index].geometry.location.lat,
                        places[index].geometry.location.lng);
                  },
                );
              },
            );
          } else {
            return Container();
          }
        } else {
          return Container();
        }
      },
    );
  }

  /// Functions
  void _returnToMapScreen(String address, double lat, double lng) {
    List<dynamic> data = [];

    data.add(address);
    data.add(lat);
    data.add(lng);

    Navigator.pop(context, data);
  }
}
