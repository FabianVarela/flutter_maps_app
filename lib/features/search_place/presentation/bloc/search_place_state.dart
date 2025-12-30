part of 'search_place_bloc.dart';

class SearchPlaceState extends Equatable {
  const SearchPlaceState({
    this.places = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  factory SearchPlaceState.initial() => const SearchPlaceState();

  final List<PlacesSearchResult> places;
  final bool isLoading;
  final String? errorMessage;

  SearchPlaceState copyWith({
    List<PlacesSearchResult>? places,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SearchPlaceState(
      places: places ?? this.places,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [places, isLoading, errorMessage];
}
