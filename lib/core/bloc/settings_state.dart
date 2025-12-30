part of 'settings_bloc.dart';

class SingleState extends Equatable {
  const SingleState({
    this.position,
    this.mapModeStyle = '',
    this.isLoadingPosition = false,
    this.isLoadingMapMode = false,
    this.errorMessage,
  });

  factory SingleState.initial() => const SingleState();

  final Position? position;
  final String mapModeStyle;
  final bool isLoadingPosition;
  final bool isLoadingMapMode;
  final String? errorMessage;

  SingleState copyWith({
    Position? position,
    String? mapModeStyle,
    bool? isLoadingPosition,
    bool? isLoadingMapMode,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SingleState(
      position: position ?? this.position,
      mapModeStyle: mapModeStyle ?? this.mapModeStyle,
      isLoadingPosition: isLoadingPosition ?? this.isLoadingPosition,
      isLoadingMapMode: isLoadingMapMode ?? this.isLoadingMapMode,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    position,
    mapModeStyle,
    isLoadingPosition,
    isLoadingMapMode,
    errorMessage,
  ];
}
