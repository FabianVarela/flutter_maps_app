part of 'map_bloc.dart';

typedef Position = ({double lat, double lng});

class MapState extends Equatable {
  const MapState({
    this.markers = const <MarkerId, Marker>{},
    this.polylines = const <PolylineId, Polyline>{},
    this.routeData,
    this.isLoadingRoute = false,
    this.errorMessage,
    this.origin,
    this.destination,
    this.address,
  });

  factory MapState.initial() => const MapState();

  final Map<MarkerId, Marker> markers;
  final Map<PolylineId, Polyline> polylines;
  final RouteData? routeData;
  final bool isLoadingRoute;
  final String? errorMessage;
  final Position? origin;
  final Position? destination;
  final String? address;

  MapState copyWith({
    Map<MarkerId, Marker>? markers,
    Map<PolylineId, Polyline>? polylines,
    RouteData? routeData,
    bool? isLoadingRoute,
    String? errorMessage,
    Position? origin,
    Position? destination,
    String? address,
    bool clearRouteData = false,
    bool clearError = false,
    bool clearDestination = false,
  }) {
    return MapState(
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
      routeData: clearRouteData ? null : (routeData ?? this.routeData),
      isLoadingRoute: isLoadingRoute ?? this.isLoadingRoute,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      origin: origin ?? this.origin,
      destination: clearDestination ? null : (destination ?? this.destination),
      address: clearDestination ? null : (address ?? this.address),
    );
  }

  @override
  List<Object?> get props => [
    markers,
    polylines,
    routeData,
    isLoadingRoute,
    errorMessage,
    origin,
    destination,
    address,
  ];
}
