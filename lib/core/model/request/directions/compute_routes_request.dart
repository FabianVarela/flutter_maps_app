import 'package:json_annotation/json_annotation.dart';

part 'compute_routes_request.g.dart';

@JsonSerializable(createFactory: false)
class ComputeRoutesRequest {
  ComputeRoutesRequest({
    required this.origin,
    required this.destination,
    required this.travelMode,
    required this.routingPreference,
    required this.computeAlternativeRoutes,
    required this.units,
  });

  final RouteLocation origin;
  final RouteLocation destination;
  final String travelMode;
  final String routingPreference;
  final bool computeAlternativeRoutes;
  final String units;

  Map<String, dynamic> toJson() => _$ComputeRoutesRequestToJson(this);
}

@JsonSerializable(createFactory: false)
class RouteLocation {
  RouteLocation({required this.location});

  final LocationWrapper location;

  Map<String, dynamic> toJson() => _$RouteLocationToJson(this);
}

@JsonSerializable(createFactory: false)
class LocationWrapper {
  LocationWrapper({required this.latLng});

  final LocationLatLng latLng;

  Map<String, dynamic> toJson() => _$LocationWrapperToJson(this);
}

@JsonSerializable(createFactory: false)
class LocationLatLng {
  LocationLatLng({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  Map<String, dynamic> toJson() => _$LocationLatLngToJson(this);
}
