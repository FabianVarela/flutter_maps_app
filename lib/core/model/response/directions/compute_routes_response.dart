import 'package:json_annotation/json_annotation.dart';

part 'compute_routes_response.g.dart';

typedef Position = ({double lat, double lng});
typedef DirectionBounds = ({Position southwest, Position northeast});
typedef DirectionStep = ({String points});
typedef DirectionInfo = ({
  List<DirectionStep> steps,
  String eta,
  String km,
  DirectionBounds bounds,
});

@JsonSerializable(createToJson: false)
class ComputeRoutesResponse {
  ComputeRoutesResponse({required this.routes});

  factory ComputeRoutesResponse.fromJson(Map<String, dynamic> json) =>
      _$ComputeRoutesResponseFromJson(json);

  final List<Route> routes;
}

@JsonSerializable(createToJson: false)
class Route {
  Route({
    required this.duration,
    required this.distanceMeters,
    required this.legs,
    required this.viewport,
  });

  factory Route.fromJson(Map<String, dynamic> json) => _$RouteFromJson(json);

  final String duration;
  final int distanceMeters;
  final List<RouteLeg> legs;
  final Viewport viewport;
}

extension RouteX on Route {
  String get eta {
    final durationSeconds = int.tryParse(duration.replaceAll('s', '')) ?? 0;
    return '${(durationSeconds / 60).round()} min';
  }

  String get km => '${(distanceMeters / 1000).toStringAsFixed(1)} km';

  List<DirectionStep> get steps {
    if (legs.isEmpty) return <DirectionStep>[];

    return [
      for (final step in legs.first.steps)
        if (step.polyline.encodedPolyline.isNotEmpty)
          (points: step.polyline.encodedPolyline),
    ];
  }

  DirectionBounds get bounds {
    return (
      southwest: (lat: viewport.low.latitude, lng: viewport.low.longitude),
      northeast: (lat: viewport.high.latitude, lng: viewport.high.longitude),
    );
  }

  DirectionInfo toDirectionInfo() {
    return (steps: steps, eta: eta, km: km, bounds: bounds);
  }
}

@JsonSerializable(createToJson: false)
class RouteLeg {
  RouteLeg({required this.steps});

  factory RouteLeg.fromJson(Map<String, dynamic> json) =>
      _$RouteLegFromJson(json);

  final List<RouteStep> steps;
}

@JsonSerializable(createToJson: false)
class RouteStep {
  RouteStep({required this.polyline});

  factory RouteStep.fromJson(Map<String, dynamic> json) =>
      _$RouteStepFromJson(json);

  final RoutePolyline polyline;
}

@JsonSerializable(createToJson: false)
class RoutePolyline {
  RoutePolyline({required this.encodedPolyline});

  factory RoutePolyline.fromJson(Map<String, dynamic> json) =>
      _$RoutePolylineFromJson(json);

  final String encodedPolyline;
}

@JsonSerializable(createToJson: false)
class Viewport {
  Viewport({required this.low, required this.high});

  factory Viewport.fromJson(Map<String, dynamic> json) =>
      _$ViewportFromJson(json);

  final ViewportCoordinate low;
  final ViewportCoordinate high;
}

@JsonSerializable(createToJson: false)
class ViewportCoordinate {
  ViewportCoordinate({required this.latitude, required this.longitude});

  factory ViewportCoordinate.fromJson(Map<String, dynamic> json) =>
      _$ViewportCoordinateFromJson(json);

  final double latitude;
  final double longitude;
}
