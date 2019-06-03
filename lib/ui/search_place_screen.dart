import 'package:flutter/material.dart';
import 'package:flutter_maps_bloc/bloc/search_place_bloc.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
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
      ),
    );
  }

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

                    List<dynamic> data = [];

                    data.add(places[index].formattedAddress);
                    data.add(places[index].geometry.location.lat);
                    data.add(places[index].geometry.location.lng);

                    Future.delayed(Duration(seconds: 2),
                        () => Navigator.pop(context, data));
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
}
