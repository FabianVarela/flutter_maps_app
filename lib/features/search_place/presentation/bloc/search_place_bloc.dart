import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_maps_app/core/client/maps_client.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:stream_transform/stream_transform.dart';

part 'search_place_event.dart';

part 'search_place_state.dart';

class SearchPlaceBloc extends Bloc<SearchPlaceEvent, SearchPlaceState> {
  SearchPlaceBloc({required this.mapsClient})
    : super(SearchPlaceState.initial()) {
    on<SearchPlaceQueryEvent>(
      _onSearchPlaceQuery,
      transformer: _debounceAndSwitch(const Duration(milliseconds: 500)),
    );
  }

  final MapsClient mapsClient;

  Future<void> _onSearchPlaceQuery(
    SearchPlaceQueryEvent event,
    Emitter<SearchPlaceState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(state.copyWith(places: [], isLoading: false, clearError: true));
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final places = await mapsClient.searchPlace(
        value: event.query,
        position: event.position,
      );
      emit(state.copyWith(places: places, isLoading: false, clearError: true));
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to search places: $error',
        ),
      );
    }
  }

  EventTransformer<E> _debounceAndSwitch<E>(Duration duration) {
    return (events, mapper) => events.debounce(duration).switchMap(mapper);
  }
}
