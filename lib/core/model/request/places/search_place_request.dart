import 'package:json_annotation/json_annotation.dart';

part 'search_place_request.g.dart';

@JsonSerializable(createFactory: false)
class SearchPlaceRequest {
  SearchPlaceRequest({required this.textQuery, required this.locationBias});

  final String textQuery;
  final LocationBias locationBias;

  Map<String, dynamic> toJson() => _$SearchPlaceRequestToJson(this);
}

@JsonSerializable(createFactory: false)
class LocationBias {
  LocationBias({required this.circle});

  final Circle circle;

  Map<String, dynamic> toJson() => _$LocationBiasToJson(this);
}

@JsonSerializable(createFactory: false)
class Circle {
  Circle({required this.center, required this.radius});

  final Center center;
  final double radius;

  Map<String, dynamic> toJson() => _$CircleToJson(this);
}

@JsonSerializable(createFactory: false)
class Center {
  Center({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  Map<String, dynamic> toJson() => _$CenterToJson(this);
}
