part of 'drag_map_bloc.dart';

abstract class DragMapEvent extends Equatable {
  const DragMapEvent();

  @override
  List<Object?> get props => [];
}

class GetInitialPositionEvent extends DragMapEvent {
  const GetInitialPositionEvent({required this.latLng, required this.idMarker});

  final LatLng latLng;
  final String idMarker;

  @override
  List<Object?> get props => [latLng, idMarker];
}

class DragMarkerEvent extends DragMapEvent {
  const DragMarkerEvent({required this.latLng, required this.idMarker});

  final LatLng latLng;
  final String idMarker;

  @override
  List<Object?> get props => [latLng, idMarker];
}

class GetAddressEvent extends DragMapEvent {
  const GetAddressEvent({required this.lat, required this.lng});

  final double lat;
  final double lng;

  @override
  List<Object?> get props => [lat, lng];
}
