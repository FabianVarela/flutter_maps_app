import 'dart:convert';

import 'package:flutter_maps_app/core/model/request/directions/compute_routes_request.dart';
import 'package:flutter_maps_app/core/model/request/places/search_place_request.dart';
import 'package:flutter_maps_app/core/model/response/directions/compute_routes_response.dart';
import 'package:flutter_maps_app/core/model/response/places/place_search_result.dart';
import 'package:http/http.dart';

class MapsClient {
  MapsClient({required this.client});

  final Client client;
  static const _mapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');

  Future<List<PlaceSearchResult>> searchPlace({
    required SearchPlaceRequest request,
  }) async {
    try {
      final placesList = ['displayName', 'formattedAddress', 'location'];
      final response = await client.post(
        Uri.https('places.googleapis.com', '/v1/places:searchText'),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _mapsApiKey,
          'X-Goog-FieldMask': placesList.map((e) => 'places.$e').join(','),
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode != 200) return [];
      final data = json.decode(response.body) as Map<String, dynamic>;

      final places = data['places'] as List<dynamic>?;
      return [
        for (final item in places ?? [])
          PlaceSearchResult.fromJson(item as Map<String, dynamic>),
      ];
    } on Exception catch (_) {
      return [];
    }
  }

  Future<DirectionInfo?> getDirectionsFromPositions({
    required ComputeRoutesRequest request,
  }) async {
    try {
      final routesList = [
        'duration',
        'distanceMeters',
        'polyline.encodedPolyline',
        'viewport',
        'legs.steps.polyline',
      ];

      final response = await client.post(
        Uri.https('routes.googleapis.com', '/directions/v2:computeRoutes'),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _mapsApiKey,
          'X-Goog-FieldMask': routesList.map((e) => 'routes.$e').join(','),
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body) as Map<String, dynamic>;
      final routesResponse = ComputeRoutesResponse.fromJson(data);

      if (routesResponse.routes.isEmpty) return null;
      return routesResponse.routes.first.toDirectionInfo();
    } on Exception catch (_) {
      return null;
    }
  }

  Future<String?> getAddressFromPosition({required Position position}) async {
    try {
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/geocode/json',
        {'latlng': '${position.lat},${position.lng}', 'key': _mapsApiKey},
      );

      final response = await client.get(uri);
      if (response.statusCode != 200) return null;

      final data = json.decode(response.body) as Map<String, dynamic>;
      if ((data['status'] as String) != 'OK') return null;

      final results = data['results'] as List<dynamic>;
      if (results.isEmpty) return null;

      final firstResult = results.first as Map<String, dynamic>;
      return firstResult['formatted_address'] as String?;
    } on Exception catch (_) {
      return null;
    }
  }
}
