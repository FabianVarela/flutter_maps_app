import 'package:equatable/equatable.dart';
import 'package:flutter_maps_app/core/gen/assets.gen.dart';
import 'package:google_maps_webservice/directions.dart';

enum MapMode { night, nightBlue, personal, uber, none }

class RouteData extends Equatable {
  const RouteData({required this.bounds, required this.km, required this.eta});

  final Bounds bounds;
  final String km;
  final String eta;

  @override
  List<Object?> get props => [bounds, km, eta];
}

typedef PositionPoint = ({double lat, double lng});

class DragMapData extends Equatable {
  const DragMapData({required this.position, this.formattedAddress});

  final PositionPoint position;
  final String? formattedAddress;

  @override
  List<Object?> get props => [position, formattedAddress];
}

extension MapModeX on MapMode {
  String get filePath => switch (this) {
    .night => Assets.mapStyles.nightMode,
    .nightBlue => Assets.mapStyles.nightBlueMode,
    .personal => Assets.mapStyles.personalMode,
    .uber => Assets.mapStyles.uberMode,
    .none => '',
  };
}
