import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_maps_app/core/client/maps_client.dart';
import 'package:flutter_maps_app/core/model/map_models.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'map_event.dart';

part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc({required this.mapsClient}) : super(MapState.initial()) {
    on<SetOriginMarkerEvent>(_onSetOriginMarker);
    on<SetDestinationMarkerEvent>(_onSetDestinationMarker);
    on<SetPolylineEvent>(_onSetPolyline);
    on<ClearMapEvent>(_onClearMap);
  }

  final MapsClient mapsClient;

  void _onSetOriginMarker(SetOriginMarkerEvent event, Emitter<MapState> emit) {
    const markerId = MarkerId('Current location');
    final updatedMarkers = Map<MarkerId, Marker>.from(state.markers);

    updatedMarkers[markerId] = Marker(
      markerId: markerId,
      position: LatLng(event.lat, event.lng),
      infoWindow: const InfoWindow(
        title: 'Current location',
        snippet: 'Current place',
      ),
    );

    emit(
      state.copyWith(
        markers: updatedMarkers,
        origin: (lat: event.lat, lng: event.lng),
      ),
    );
  }

  void _onSetDestinationMarker(
    SetDestinationMarkerEvent event,
    Emitter<MapState> emit,
  ) {
    const markerId = MarkerId('Destination location');
    final updatedMarkers = Map<MarkerId, Marker>.from(state.markers);

    updatedMarkers[markerId] = Marker(
      markerId: markerId,
      position: LatLng(event.lat, event.lng),
      infoWindow: const InfoWindow(
        title: 'Destination location',
        snippet: 'Destination place',
      ),
    );

    emit(
      state.copyWith(
        markers: updatedMarkers,
        destination: (lat: event.lat, lng: event.lng),
      ),
    );
  }

  Future<void> _onSetPolyline(
    SetPolylineEvent event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(isLoadingRoute: true, clearError: true));

    try {
      final direction = await mapsClient.getDirectionsFromPositions(
        event.origin,
        event.destination,
      );

      if (direction == null) {
        emit(
          state.copyWith(
            isLoadingRoute: false,
            errorMessage: 'Unable to fetch route data',
          ),
        );
        return;
      }

      final pointList = <LatLng>[];
      for (final step in direction.steps) {
        _decodePolyLine(step.polyline.points).forEach(pointList.add);
      }

      const polylineId = PolylineId('polyline');
      final updatedPolylines = Map<PolylineId, Polyline>.from(state.polylines);

      updatedPolylines[polylineId] = Polyline(
        polylineId: polylineId,
        points: pointList,
        color: event.polylineColor,
        width: 5,
      );

      emit(
        state.copyWith(
          polylines: updatedPolylines,
          routeData: RouteData(
            bounds: direction.bounds,
            km: direction.km,
            eta: direction.eta,
          ),
          isLoadingRoute: false,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingRoute: false,
          errorMessage: 'Failed to load route: $error',
        ),
      );
    }
  }

  void _onClearMap(ClearMapEvent event, Emitter<MapState> emit) {
    emit(
      state.copyWith(
        polylines: <PolylineId, Polyline>{},
        clearRouteData: true,
        clearError: true,
        clearDestination: true,
      ),
    );
  }

  List<LatLng> _decodePolyLine(String encoded) {
    final poly = <LatLng>[];
    final len = encoded.length;

    var index = 0;
    var lat = 0;
    var lng = 0;

    while (index < len) {
      int b;
      var shift = 0;
      var result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final dLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dLat;
      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final dLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dLng;

      final p = LatLng(lat.toDouble() / 1E5, lng.toDouble() / 1E5);
      poly.add(p);
    }

    return poly;
  }
}
