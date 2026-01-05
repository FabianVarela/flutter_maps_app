part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.position,
    this.mapMode = MapMode.none,
    this.mapModeStyle = '',
    this.showTraffic = false,
    this.showTransport = false,
    this.isLoadingPosition = false,
    this.isLoadingMapMode = false,
    this.errorMessage,
  });

  factory SettingsState.initial() => const SettingsState();

  final Position? position;
  final MapMode mapMode;
  final String mapModeStyle;
  final bool showTraffic;
  final bool showTransport;
  final bool isLoadingPosition;
  final bool isLoadingMapMode;
  final String? errorMessage;

  SettingsState copyWith({
    Position? position,
    MapMode? mapMode,
    String? mapModeStyle,
    bool? showTraffic,
    bool? showTransport,
    bool? isLoadingPosition,
    bool? isLoadingMapMode,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SettingsState(
      position: position ?? this.position,
      mapMode: mapMode ?? this.mapMode,
      mapModeStyle: mapModeStyle ?? this.mapModeStyle,
      showTraffic: showTraffic ?? this.showTraffic,
      showTransport: showTransport ?? this.showTransport,
      isLoadingPosition: isLoadingPosition ?? this.isLoadingPosition,
      isLoadingMapMode: isLoadingMapMode ?? this.isLoadingMapMode,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    position,
    mapMode,
    mapModeStyle,
    showTraffic,
    showTransport,
    isLoadingPosition,
    isLoadingMapMode,
    errorMessage,
  ];
}
