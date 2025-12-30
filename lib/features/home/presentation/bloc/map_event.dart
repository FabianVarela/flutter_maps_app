part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

class SetOriginMarkerEvent extends MapEvent {
  const SetOriginMarkerEvent({required this.lat, required this.lng});

  final double lat;
  final double lng;

  @override
  List<Object?> get props => [lat, lng];
}

class SetDestinationMarkerEvent extends MapEvent {
  const SetDestinationMarkerEvent({required this.lat, required this.lng});

  final double lat;
  final double lng;

  @override
  List<Object?> get props => [lat, lng];
}

class SetPolylineEvent extends MapEvent {
  const SetPolylineEvent({
    required this.origin,
    required this.destination,
    required this.polylineColor,
  });

  final Position origin;
  final Position destination;
  final Color polylineColor;

  @override
  List<Object?> get props => [origin, destination, polylineColor];
}

class ClearMapEvent extends MapEvent {
  const ClearMapEvent();
}
