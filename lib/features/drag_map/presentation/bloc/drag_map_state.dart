part of 'drag_map_bloc.dart';

class DragMapState extends Equatable {
  const DragMapState({
    this.markers = const <MarkerId, Marker>{},
    this.isFirstTime = false,
    this.dragMapData,
    this.isLoadingAddress = false,
    this.errorMessage,
  });

  factory DragMapState.initial() => const DragMapState();

  final Map<MarkerId, Marker> markers;
  final bool isFirstTime;
  final DragMapData? dragMapData;
  final bool isLoadingAddress;
  final String? errorMessage;

  DragMapState copyWith({
    Map<MarkerId, Marker>? markers,
    bool? isFirstTime,
    DragMapData? dragMapData,
    bool? isLoadingAddress,
    String? errorMessage,
    bool clearDragMapData = false,
    bool clearError = false,
  }) {
    return DragMapState(
      markers: markers ?? this.markers,
      isFirstTime: isFirstTime ?? this.isFirstTime,
      dragMapData: clearDragMapData ? null : (dragMapData ?? this.dragMapData),
      isLoadingAddress: isLoadingAddress ?? this.isLoadingAddress,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    markers,
    isFirstTime,
    dragMapData,
    isLoadingAddress,
    errorMessage,
  ];
}
