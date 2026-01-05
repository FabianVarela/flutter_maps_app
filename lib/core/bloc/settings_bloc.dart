import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_maps_app/core/client/preferences.dart';
import 'package:flutter_maps_app/core/model/map_models.dart';
import 'package:geolocator/geolocator.dart';

part 'settings_event.dart';

part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({required this.preferences}) : super(SettingsState.initial()) {
    on<StartPositionStreamEvent>(_onStartPositionStream);
    on<InitMapModeEvent>(_onInitMapMode);
    on<ChangeMapModeEvent>(_onChangeMapMode);
    on<ToggleTrafficEvent>(_onToggleTraffic);
    on<ToggleTransportEvent>(_onToggleTransport);
  }

  final Preferences preferences;

  static const _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );

  Future<void> _onStartPositionStream(
    StartPositionStreamEvent event,
    Emitter<SettingsState> emit,
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
    Emitter<SettingsState> emit,
  ) async {
    final mapMode = preferences.getMapMode();
    if (mapMode == null || mapMode.isEmpty) return;

    emit(state.copyWith(isLoadingMapMode: true, clearError: true));

    try {
      final currentMapMode = MapMode.values.byName(mapMode);
      emit(
        state.copyWith(
          mapMode: currentMapMode,
          mapModeStyle: switch (currentMapMode.filePath.isEmpty) {
            true => '',
            false => await rootBundle.loadString(currentMapMode.filePath),
          },
          isLoadingMapMode: false,
          clearError: true,
        ),
      );
    } on Exception catch (_) {
      emit(
        state.copyWith(
          mapMode: MapMode.none,
          mapModeStyle: '',
          isLoadingMapMode: false,
          clearError: true,
        ),
      );
    }
  }

  Future<void> _onChangeMapMode(
    ChangeMapModeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoadingMapMode: true, clearError: true));

    try {
      await preferences.saveMapMode(event.mode.name);
      emit(
        state.copyWith(
          mapMode: event.mode,
          mapModeStyle: switch (event.mode.filePath.isEmpty) {
            true => '',
            false => await rootBundle.loadString(event.mode.filePath),
          },
          isLoadingMapMode: false,
          clearError: true,
        ),
      );
    } on Exception catch (error) {
      emit(
        state.copyWith(
          mapMode: MapMode.none,
          mapModeStyle: '',
          isLoadingMapMode: false,
          errorMessage: 'Failed to change map mode: $error',
        ),
      );
    }
  }

  void _onToggleTraffic(ToggleTrafficEvent event, Emitter<SettingsState> emit) {
    emit(state.copyWith(showTraffic: event.show));
  }

  void _onToggleTransport(
    ToggleTransportEvent event,
    Emitter<SettingsState> emit,
  ) => emit(state.copyWith(showPublicTransport: event.show));

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
