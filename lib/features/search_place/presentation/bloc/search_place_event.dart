part of 'search_place_bloc.dart';

typedef Position = ({double lat, double lng});

abstract class SearchPlaceEvent extends Equatable {
  const SearchPlaceEvent();

  @override
  List<Object?> get props => [];
}

class SearchPlaceQueryEvent extends SearchPlaceEvent {
  const SearchPlaceQueryEvent({required this.query, required this.position});

  final String query;
  final Position position;

  @override
  List<Object?> get props => [query, position];
}
