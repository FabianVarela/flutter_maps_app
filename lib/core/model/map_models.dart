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

class DragMapData extends Equatable {
  const DragMapData({
    required this.latitude,
    required this.longitude,
    this.formattedAddress,
  });

  final double latitude;
  final double longitude;
  final String? formattedAddress;

  @override
  List<Object?> get props => [latitude, longitude, formattedAddress];
}
