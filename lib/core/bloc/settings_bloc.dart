import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_maps_app/core/client/preferences.dart';
import 'package:geolocator/geolocator.dart';

part 'settings_event.dart';

part 'settings_state.dart';

class SingleBloc extends Bloc<SingleEvent, SingleState> {
  SingleBloc({required this.preferences}) : super(SingleState.initial()) {
    on<StartPositionStreamEvent>(_onStartPositionStream);
    on<InitMapModeEvent>(_onInitMapMode);
    on<ChangeMapModeEvent>(_onChangeMapMode);
  }

  final Preferences preferences;

  static const _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );

  Future<void> _onStartPositionStream(
    StartPositionStreamEvent event,
    Emitter<SingleState> emit,
  ) async {
    emit(state.copyWith(isLoadingPosition: true, clearError: true));

    try {
      await _setupPermissions();

      await emit.forEach<Position>(
        Geolocator.getPositionStream(locationSettings: _locationSettings),
        onData: (position) => state.copyWith(
          position: position,
          isLoadingPosition: false,
          clearError: true,
        ),
        onError: (error, _) => state.copyWith(
          isLoadingPosition: false,
          errorMessage: error.toString(),
        ),
      );
    } on Exception catch (error) {
      emit(
        state.copyWith(
          isLoadingPosition: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onInitMapMode(
    InitMapModeEvent event,
    Emitter<SingleState> emit,
  ) async {
    final mapMode = preferences.getMapMode();
    if (mapMode == null || mapMode.isEmpty) return;

    emit(state.copyWith(isLoadingMapMode: true, clearError: true));

    try {
      emit(
        state.copyWith(
          mapMode: await rootBundle.loadString('assets/$mapMode.json'),
          isLoadingMapMode: false,
          clearError: true,
        ),
      );
    } on Exception catch (_) {
      emit(
        state.copyWith(mapMode: '', isLoadingMapMode: false, clearError: true),
      );
    }
  }

  Future<void> _onChangeMapMode(
    ChangeMapModeEvent event,
    Emitter<SingleState> emit,
  ) async {
    emit(state.copyWith(isLoadingMapMode: true, clearError: true));

    try {
      await preferences.saveMapMode(event.mode);
      emit(
        state.copyWith(
          mapMode: switch (event.mode.isEmpty) {
            true => '',
            false => await rootBundle.loadString('assets/${event.mode}.json'),
          },
          isLoadingMapMode: false,
          clearError: true,
        ),
      );
    } on Exception catch (error) {
      emit(
        state.copyWith(
          mapMode: '',
          isLoadingMapMode: false,
          errorMessage: 'Failed to change map mode: $error',
        ),
      );
    }
  }

  Future<void> _setupPermissions() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services are disabled.');

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }
  }
}
