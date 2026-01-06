// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compute_routes_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComputeRoutesResponse _$ComputeRoutesResponseFromJson(
  Map<String, dynamic> json,
) => ComputeRoutesResponse(
  routes: (json['routes'] as List<dynamic>)
      .map((e) => Route.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Route _$RouteFromJson(Map<String, dynamic> json) => Route(
  duration: json['duration'] as String,
  distanceMeters: (json['distanceMeters'] as num).toInt(),
  legs: (json['legs'] as List<dynamic>)
      .map((e) => RouteLeg.fromJson(e as Map<String, dynamic>))
      .toList(),
  viewport: Viewport.fromJson(json['viewport'] as Map<String, dynamic>),
);

RouteLeg _$RouteLegFromJson(Map<String, dynamic> json) => RouteLeg(
  steps: (json['steps'] as List<dynamic>)
      .map((e) => RouteStep.fromJson(e as Map<String, dynamic>))
      .toList(),
);

RouteStep _$RouteStepFromJson(Map<String, dynamic> json) => RouteStep(
  polyline: RoutePolyline.fromJson(json['polyline'] as Map<String, dynamic>),
);

RoutePolyline _$RoutePolylineFromJson(Map<String, dynamic> json) =>
    RoutePolyline(encodedPolyline: json['encodedPolyline'] as String);

Viewport _$ViewportFromJson(Map<String, dynamic> json) => Viewport(
  low: ViewportCoordinate.fromJson(json['low'] as Map<String, dynamic>),
  high: ViewportCoordinate.fromJson(json['high'] as Map<String, dynamic>),
);

ViewportCoordinate _$ViewportCoordinateFromJson(Map<String, dynamic> json) =>
    ViewportCoordinate(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
