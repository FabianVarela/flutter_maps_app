import 'package:google_maps_webservice/places.dart';
import 'package:rxdart/rxdart.dart';

class SearchPlaceBloc {
  final _placeList = BehaviorSubject<List<PlacesSearchResult>>();

  final _isLoading = BehaviorSubject<bool>();

  Stream<List<PlacesSearchResult>> get placeList => _placeList.stream;

  Stream<bool> get isLoading => _isLoading.stream;

  Future<void> searchPlace(String value, double lat, double lng) async {
    _isLoading.sink.add(true);

    final places = GoogleMapsPlaces(
      apiKey: const String.fromEnvironment('GOOGLE_MAPS_API_KEY'),
    );
    final result = await places.searchByText(
      value,
      location: Location(lat: lat, lng: lng),
      radius: 1000,
    );

    _placeList.sink.add(
      result.status == 'OK' ? result.results : <PlacesSearchResult>[],
    );
    _isLoading.sink.add(false);
  }

  void dispose() {
    _placeList.close();
    _isLoading.close();
  }
}
