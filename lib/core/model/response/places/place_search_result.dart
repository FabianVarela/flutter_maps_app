import 'package:json_annotation/json_annotation.dart';

part 'place_search_result.g.dart';

@JsonSerializable(createToJson: false)
class PlaceSearchResult {
  PlaceSearchResult({
    required this.displayName,
    required this.formattedAddress,
    required this.location,
  });

  factory PlaceSearchResult.fromJson(Map<String, dynamic> json) =>
      _$PlaceSearchResultFromJson(json);

  final DisplayName displayName;
  final String formattedAddress;
  final Location location;

  String get name => displayName.text;

  double get lat => location.latitude;

  double get lng => location.longitude;
}

@JsonSerializable(createToJson: false)
class DisplayName {
  DisplayName({required this.text});

  factory DisplayName.fromJson(Map<String, dynamic> json) =>
      _$DisplayNameFromJson(json);

  final String text;
}

@JsonSerializable(createToJson: false)
class Location {
  Location({required this.latitude, required this.longitude});

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  final double latitude;
  final double longitude;
}
