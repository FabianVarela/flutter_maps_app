import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_maps_app/core/client/maps_client.dart';
import 'package:flutter_maps_app/core/model/request/places/search_place_request.dart';
import 'package:flutter_maps_app/core/model/response/places/place_search_result.dart';
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
      final position = event.position;
      final places = await mapsClient.searchPlace(
        request: SearchPlaceRequest(
          textQuery: event.query,
          locationBias: LocationBias(
            circle: Circle(
              center: Center(latitude: position.lat, longitude: position.lng),
              radius: 10000,
            ),
          ),
        ),
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
