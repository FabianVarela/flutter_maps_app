import 'package:flutter_maps_bloc/bloc/base_bloc.dart';
import 'package:flutter_maps_bloc/common/google_api_key.dart';
import 'package:rxdart/rxdart.dart';
import 'package:google_maps_webservice/places.dart';

class SearchPlaceBloc with GoogleApiKey implements BaseBloc {
  /// Subjects or StreamControllers
  final BehaviorSubject<List<PlacesSearchResult>> _placeList =
      BehaviorSubject<List<PlacesSearchResult>>();

  final BehaviorSubject<bool> _isLoading = BehaviorSubject<bool>();

  /// Observables
  Observable<List<PlacesSearchResult>> get placeList => _placeList.stream;

  Observable<bool> get isLoading => _isLoading.stream;

  /// Functions
  void searchPlace(String value, double lat, double lng) async {
    _isLoading.sink.add(true);

    final GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: getApiKey());
    final PlacesSearchResponse result = await places.searchByText(
      value,
      location: Location(lat, lng),
      radius: 1000,
    );

    if (result.status == 'OK')
      _placeList.sink.add(result.results);
    else
      _placeList.sink.add(<PlacesSearchResult>[]);

    _isLoading.sink.add(false);
  }

  /// Override functions
  @override
  void dispose() {
    _placeList.close();
    _isLoading.close();
  }
}
