part of 'settings_bloc.dart';

class SingleState extends Equatable {
  const SingleState({
    this.position,
    this.mapMode = '',
    this.isLoadingPosition = false,
    this.isLoadingMapMode = false,
    this.errorMessage,
  });

  factory SingleState.initial() => const SingleState();

  final Position? position;
  final String mapMode;
  final bool isLoadingPosition;
  final bool isLoadingMapMode;
  final String? errorMessage;

  SingleState copyWith({
    Position? position,
    String? mapMode,
    bool? isLoadingPosition,
    bool? isLoadingMapMode,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SingleState(
      position: position ?? this.position,
      mapMode: mapMode ?? this.mapMode,
      isLoadingPosition: isLoadingPosition ?? this.isLoadingPosition,
      isLoadingMapMode: isLoadingMapMode ?? this.isLoadingMapMode,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    position,
    mapMode,
    isLoadingPosition,
    isLoadingMapMode,
    errorMessage,
  ];
}
