// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_search_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaceSearchResult _$PlaceSearchResultFromJson(Map<String, dynamic> json) =>
    PlaceSearchResult(
      displayName: DisplayName.fromJson(
        json['displayName'] as Map<String, dynamic>,
      ),
      formattedAddress: json['formattedAddress'] as String,
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
    );

DisplayName _$DisplayNameFromJson(Map<String, dynamic> json) =>
    DisplayName(text: json['text'] as String);

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
);
