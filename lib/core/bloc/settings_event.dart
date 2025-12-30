part of 'settings_bloc.dart';

abstract class SingleEvent extends Equatable {
  const SingleEvent();

  @override
  List<Object?> get props => [];
}

class StartPositionStreamEvent extends SingleEvent {
  const StartPositionStreamEvent();
}

class InitMapModeEvent extends SingleEvent {
  const InitMapModeEvent();
}

class ChangeMapModeEvent extends SingleEvent {
  const ChangeMapModeEvent(this.mode);

  final MapMode mode;

  @override
  List<Object?> get props => [mode];
}
