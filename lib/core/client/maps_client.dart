import 'package:google_maps_webservice/directions.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:google_maps_webservice/places.dart';

typedef Position = ({double lat, double lng});

typedef DirectionInfo = ({
  List<Step> steps,
  String eta,
  String km,
  Bounds bounds,
});

class MapsClient {
  static const _mapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');

  Future<List<PlacesSearchResult>> searchPlace({
    required String value,
    required Position position,
  }) async {
    final places = GoogleMapsPlaces(apiKey: _mapsApiKey);
    final result = await places.searchByText(
      value,
      location: Location(lat: position.lat, lng: position.lng),
      radius: 1000,
    );
    return result.status == 'OK' ? result.results : <PlacesSearchResult>[];
  }

  Future<DirectionInfo?> getDirectionsFromPositions({
    required Position origin,
    required Position destination,
    required ({bool showTraffic, bool isTransport}) params,
  }) async {
    try {
      final directions = GoogleMapsDirections(apiKey: _mapsApiKey);
      final response = await directions.directionsWithLocation(
        Location(lat: origin.lat, lng: origin.lng),
        Location(lat: destination.lat, lng: destination.lng),
        trafficModel: params.showTraffic ? .pessimistic : .optimistic,
        travelMode: params.isTransport ? .transit : .driving,
        departureTime: DateTime.now(),
      );

      if (!response.isOkay || response.routes.isEmpty) return null;
      return (
        steps: response.routes.first.legs.first.steps,
        eta: response.routes.first.legs.first.duration.text,
        km: response.routes.first.legs.first.distance.text,
        bounds: response.routes.first.bounds,
      );
    } on Exception catch (_) {
      return null;
    }
  }

  Future<String?> getAddressFromPosition({required Position position}) async {
    final geoCoding = GoogleMapsGeocoding(apiKey: _mapsApiKey);
    final response = await geoCoding.searchByLocation(
      Location(lat: position.lat, lng: position.lng),
    );

    if (!response.isOkay) return null;
    return response.results.firstOrNull?.formattedAddress;
  }
}
