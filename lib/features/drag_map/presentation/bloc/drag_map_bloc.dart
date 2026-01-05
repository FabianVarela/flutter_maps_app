import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_maps_app/core/client/maps_client.dart';
import 'package:flutter_maps_app/core/model/map_models.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'drag_map_event.dart';

part 'drag_map_state.dart';

class DragMapBloc extends Bloc<DragMapEvent, DragMapState> {
  DragMapBloc({required this.mapsClient}) : super(DragMapState.initial()) {
    on<GetInitialPositionEvent>(_onGetInitialPosition);
    on<DragMarkerEvent>(_onDragMarker);
    on<GetAddressEvent>(_onGetAddress);
  }

  final MapsClient mapsClient;

  Future<void> _onGetInitialPosition(
    GetInitialPositionEvent event,
    Emitter<DragMapState> emit,
  ) async {
    final markerId = MarkerId(event.idMarker);
    final updatedMarkers = Map<MarkerId, Marker>.from(state.markers);
    updatedMarkers[markerId] = Marker(
      markerId: markerId,
      position: event.latLng,
    );
    emit(state.copyWith(markers: updatedMarkers, isFirstTime: true));

    await Future<void>.delayed(const Duration(seconds: 3));
    emit(state.copyWith(isFirstTime: false));
  }

  void _onDragMarker(DragMarkerEvent event, Emitter<DragMapState> emit) {
    final markerId = MarkerId(event.idMarker);
    final updatedMarker = state.markers[markerId]?.copyWith(
      positionParam: event.latLng,
    );

    if (updatedMarker != null) {
      final updatedMarkers = Map<MarkerId, Marker>.from(state.markers);
      updatedMarkers[markerId] = updatedMarker;

      emit(state.copyWith(markers: updatedMarkers));
    }
  }

  Future<void> _onGetAddress(
    GetAddressEvent event,
    Emitter<DragMapState> emit,
  ) async {
    emit(state.copyWith(isLoadingAddress: true, clearError: true));

    try {
      final address = await mapsClient.getAddressFromPosition(
        position: (lat: event.lat, lng: event.lng),
      );

      emit(
        state.copyWith(
          dragMapData: address != null
              ? DragMapData(
                  position: (lat: event.lat, lng: event.lng),
                  formattedAddress: address,
                )
              : null,
          isLoadingAddress: false,
          clearError: address != null,
          errorMessage: address == null ? 'Unable to fetch address' : null,
        ),
      );
    } on Exception catch (error) {
      emit(
        state.copyWith(
          isLoadingAddress: false,
          errorMessage: 'Failed to load address: $error',
        ),
      );
    }
  }
}
