import 'package:flutter_maps_app/core/client/maps_client.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:rxdart/rxdart.dart';

class SearchPlaceBloc {
  SearchPlaceBloc({required this.mapsClient});

  final MapsClient mapsClient;

  final _placeList = BehaviorSubject<List<PlacesSearchResult>>();

  final _isLoading = BehaviorSubject<bool>();

  Stream<List<PlacesSearchResult>> get placeList => _placeList.stream;

  Stream<bool> get isLoading => _isLoading.stream;

  Future<void> searchPlace(String value, double lat, double lng) async {
    _isLoading.sink.add(true);
    final place = await mapsClient.searchPlace(value, (lat: lat, lng: lng));

    _placeList.sink.add(place);
    _isLoading.sink.add(false);
  }

  void dispose() {
    _placeList.close();
    _isLoading.close();
  }
}

final searchPlaceBloc = SearchPlaceBloc(mapsClient: MapsClient());
