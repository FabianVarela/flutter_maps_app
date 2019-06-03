import 'dart:io';

import 'package:rxdart/rxdart.dart';

import 'base_bloc.dart';
import 'package:google_maps_webservice/places.dart';

class SearchPlaceBloc implements BaseBloc {
  /// Subjects or StreamControllers
  final _placeList = BehaviorSubject<List<PlacesSearchResult>>();
  final _isLoading = BehaviorSubject<bool>();

  /// Observables
  Observable<List<PlacesSearchResult>> get placeList => _placeList.stream;

  Observable<bool> get isLoading => _isLoading.stream;

  /// Functions
  void searchPlace(String value, double lat, double lng) async {
    _isLoading.sink.add(true);

    String apiKey = Platform.isAndroid
        ? ""
        : "";

    final places = GoogleMapsPlaces(apiKey: apiKey);
    final result = await places.searchByText(
      value,
      location: Location(lat, lng),
      radius: 1000,
    );

    if (result.status == "OK")
      _placeList.sink.add(result.results);
    else
      _placeList.sink.add([]);

    _isLoading.sink.add(false);
  }

  /// Override functions
  @override
  void dispose() {
    _placeList.close();
    _isLoading.close();
  }
}
