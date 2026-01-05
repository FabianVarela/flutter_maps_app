part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class StartPositionStreamEvent extends SettingsEvent {
  const StartPositionStreamEvent();
}

class InitMapModeEvent extends SettingsEvent {
  const InitMapModeEvent();
}

class ChangeMapModeEvent extends SettingsEvent {
  const ChangeMapModeEvent(this.mode);

  final MapMode mode;

  @override
  List<Object?> get props => [mode];
}

class ToggleTrafficEvent extends SettingsEvent {
  const ToggleTrafficEvent({required this.show});

  final bool show;

  @override
  List<Object?> get props => [show];
}

class ToggleTransportEvent extends SettingsEvent {
  const ToggleTransportEvent({required this.show});

  final bool show;

  @override
  List<Object?> get props => [show];
}
