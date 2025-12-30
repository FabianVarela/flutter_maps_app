import 'package:equatable/equatable.dart';
import 'package:google_maps_webservice/directions.dart';

class RouteData extends Equatable {
  const RouteData({required this.bounds, required this.km, required this.eta});

  final Bounds bounds;
  final String km;
  final String eta;

  @override
  List<Object?> get props => [bounds, km, eta];
}

typedef Position = ({double lat, double lng});

class DragMapData extends Equatable {
  const DragMapData({required this.position, this.formattedAddress});

  final Position position;
  final String? formattedAddress;

  @override
  List<Object?> get props => [position, formattedAddress];
}
